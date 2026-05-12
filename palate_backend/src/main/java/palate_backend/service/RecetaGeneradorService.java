package palate_backend.service;

import palate_backend.dto.AlimentoDTO;
import palate_backend.dto.IngredienteDTO;
import palate_backend.dto.RecetaDTO;
import palate_backend.enums.DificultadReceta;
import palate_backend.enums.MetodoPreparacion;
import palate_backend.enums.RolIngrediente;
import palate_backend.model.*;
import palate_backend.repository.AlimentoRepository;
import palate_backend.repository.IntoleranciaUsuarioRepository;
import palate_backend.repository.ProductoDespensaRepository;
import palate_backend.repository.RecetaRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class RecetaGeneradorService implements RecetaService {

    private final RecetaRepository recetaRepository;
    private final AlimentoRepository alimentoRepository;
    private final IAService iaService;
    private final IntoleranciaUsuarioRepository intoleranciaRepository;
    private final ProductoDespensaRepository productoDespensaRepository;
    private final ClasificadorImagen clasificadorImagen;
    private final PexelsImagenService pexelsImagenService;
    private final FluxImagenService fluxImagenService;

    @Autowired
    public RecetaGeneradorService(RecetaRepository recetaRepository,
                                  AlimentoRepository alimentoRepository,
                                  IAService iaService,
                                  IntoleranciaUsuarioRepository intoleranciaRepository,
                                  ProductoDespensaRepository productoDespensaRepository,
                                  ClasificadorImagen clasificadorImagen,
                                  PexelsImagenService pexelsImagenService,
                                  FluxImagenService fluxImagenService) {
        this.recetaRepository = recetaRepository;
        this.alimentoRepository = alimentoRepository;
        this.iaService = iaService;
        this.intoleranciaRepository = intoleranciaRepository;
        this.productoDespensaRepository = productoDespensaRepository;
        this.clasificadorImagen = clasificadorImagen;
        this.pexelsImagenService = pexelsImagenService;
        this.fluxImagenService = fluxImagenService;
    }

    /**
     * Resuelve la imagen en cascada: FLUX -> Pexels -> pool tematico.
     */
    String resolverImagen(Receta receta) {
        Optional<String> flux = fluxImagenService.generarYGuardarConPrompt(
                receta.getId(), construirPromptEnriquecido(receta));
        if (flux.isPresent()) return flux.get();

        Optional<String> pexels = pexelsImagenService.buscarImagen(receta.getTitulo());
        return pexels.orElseGet(() -> clasificadorImagen.elegirImagen(receta));
    }

    @Override
    @Transactional
    public Optional<String> regenerarImagen(Long recetaId) {
        Optional<Receta> opt = recetaRepository.findById(recetaId);
        if (opt.isEmpty()) return Optional.empty();

        Receta receta = opt.get();
        String nueva = resolverImagen(receta);
        receta.setImagenUrl(nueva);
        recetaRepository.save(receta);
        return Optional.of(nueva);
    }

    private String construirPromptEnriquecido(Receta receta) {
        StringBuilder ingredientes = new StringBuilder();
        if (receta.getIngredientes() != null) {
            int contador = 0;
            for (RecetaAlimento ra : receta.getIngredientes()) {
                if (ra.getAlimento() == null) continue;
                if (contador > 0) ingredientes.append(", ");
                ingredientes.append(ra.getAlimento().getNombre().toLowerCase());
                contador++;
                if (contador >= 5) break;
            }
        }

        String metodo = "";
        if (receta.getIngredientes() != null) {
            for (RecetaAlimento ra : receta.getIngredientes()) {
                if (ra.getRol() == RolIngrediente.PROTAGONISTA
                        && ra.getMetodoPreparacion() != null) {
                    metodo = ra.getMetodoPreparacion().name().toLowerCase().replace('_', ' ');
                    break;
                }
            }
        }

        StringBuilder prompt = new StringBuilder();
        prompt.append("Professional food photography of \"")
                .append(receta.getTitulo())
                .append("\", a traditional Spanish/Mediterranean dish");
        if (!ingredientes.isEmpty()) {
            prompt.append(". Made with: ").append(ingredientes);
        }
        if (!metodo.isEmpty()) {
            prompt.append(". Cooking method: ").append(metodo);
        }
        prompt.append(". Overhead shot, neutral ceramic plate, warm natural ")
                .append("lighting, terracotta tones, appetizing, high detail, ")
                .append("authentic Mediterranean cuisine, no text, no watermark, ")
                .append("no people, no hands");
        return prompt.toString();
    }

    @Override
    @Transactional(readOnly = true)
    public List<RecetaDTO> obtenerTodas() {
        List<Receta> recetas = recetaRepository.findAll();
        List<RecetaDTO> resultado = new ArrayList<>();
        for (Receta r : recetas) {
            resultado.add(recetaToDTO(r));
        }
        return resultado;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<RecetaDTO> obtenerPorId(Long id) {
        Optional<Receta> receta = recetaRepository.findById(id);
        if (receta.isPresent()) {
            return Optional.of(recetaToDTO(receta.get()));
        }
        return Optional.empty();
    }

    @Override
    @Transactional
    public RecetaDTO generarYGuardar(String descripcion) throws Exception {
        String descripcionParaCache = limpiarSufijoDificultad(descripcion);
        List<Receta> cache = recetaRepository.buscarEnCache("%" + descripcionParaCache.toLowerCase() + "%");
        if (!cache.isEmpty()) {
            return recetaToDTO(cache.get(0));
        }

        Map<String, Object> recetaMap = iaService.generarReceta(descripcion);
        Receta receta = construirYPersistirReceta(recetaMap);
        return recetaToDTO(receta);
    }

    private String limpiarSufijoDificultad(String descripcion) {
        if (descripcion == null) return "";
        return descripcion.replaceAll("\\s*\\(dificultad:[^)]+\\)", "").trim();
    }

    @Override
    @Transactional
    public RecetaDTO generarYGuardarConAversion(String descripcion, Long intoleranciaId) throws Exception {
        IntoleranciaUsuario intolerancia = intoleranciaRepository.findById(intoleranciaId)
                .orElseThrow(() -> new Exception("Intolerancia no encontrada"));

        List<Map<String, Object>> motivos = new ArrayList<>();
        for (MotivoRechazo m : intolerancia.getMotivos()) {
            motivos.add(Map.of("tipo", m.getTipo().name(), "intensidad", m.getIntensidad()));
        }

        Map<String, Object> recetaMap = iaService.generarRecetaConAversion(
                descripcion,
                intolerancia.getAlimento().getNombre(),
                intolerancia.getNivelRechazo(),
                motivos
        );

        Receta receta = construirYPersistirReceta(recetaMap);
        return recetaToDTO(receta);
    }

    @Override
    @Transactional
    public RecetaDTO generarYGuardarConAversiones(String descripcion, List<Long> intoleranciaIds) throws Exception {
        if (intoleranciaIds == null || intoleranciaIds.isEmpty()) {
            return generarYGuardar(descripcion);
        }
        if (intoleranciaIds.size() == 1) {
            return generarYGuardarConAversion(descripcion, intoleranciaIds.get(0));
        }

        List<IAService.AversionPromptInfo> aversiones = resolverAversiones(intoleranciaIds);
        Map<String, Object> recetaMap = iaService.generarRecetaConAversiones(descripcion, aversiones);
        Receta receta = construirYPersistirReceta(recetaMap);
        return recetaToDTO(receta);
    }

    @Override
    @Transactional
    public RecetaDTO generarYGuardarConDespensaYAversiones(Long usuarioId, List<Long> intoleranciaIds, String descripcion) throws Exception {
        List<ProductoDespensa> productos = productoDespensaRepository.findByUsuarioIdAndConsumidoFalse(usuarioId);
        List<String> ingredientesDespensa = new ArrayList<>();
        for (ProductoDespensa p : productos) {
            if (p.getAlimento() != null) {
                ingredientesDespensa.add(p.getAlimento().getNombre());
            }
        }

        if (intoleranciaIds == null || intoleranciaIds.isEmpty()) {
            Map<String, Object> recetaMap = iaService.generarRecetaConDespensa(descripcion, ingredientesDespensa);
            return recetaToDTO(construirYPersistirReceta(recetaMap));
        }
        if (intoleranciaIds.size() == 1) {
            return generarYGuardarConDespensa(usuarioId, intoleranciaIds.get(0), descripcion);
        }

        List<IAService.AversionPromptInfo> aversiones = resolverAversiones(intoleranciaIds);
        Map<String, Object> recetaMap = iaService.generarRecetaConDespensaYAversiones(descripcion, ingredientesDespensa, aversiones);
        Receta receta = construirYPersistirReceta(recetaMap);
        return recetaToDTO(receta);
    }

    private List<IAService.AversionPromptInfo> resolverAversiones(List<Long> intoleranciaIds) throws Exception {
        List<IAService.AversionPromptInfo> aversiones = new ArrayList<>();
        for (Long id : intoleranciaIds) {
            IntoleranciaUsuario intolerancia = intoleranciaRepository.findById(id)
                    .orElseThrow(() -> new Exception("Intolerancia no encontrada: " + id));
            List<Map<String, Object>> motivos = new ArrayList<>();
            for (MotivoRechazo m : intolerancia.getMotivos()) {
                motivos.add(Map.of("tipo", m.getTipo().name(), "intensidad", m.getIntensidad()));
            }
            aversiones.add(new IAService.AversionPromptInfo(
                    intolerancia.getAlimento().getNombre(),
                    intolerancia.getNivelRechazo(),
                    motivos
            ));
        }
        return aversiones;
    }

    @Override
    @Transactional
    public RecetaDTO generarYGuardarConDespensa(Long usuarioId, Long intoleranciaId, String descripcion) throws Exception {
        List<ProductoDespensa> productos = productoDespensaRepository.findByUsuarioIdAndConsumidoFalse(usuarioId);

        List<String> ingredientesDespensa = new ArrayList<>();
        for (ProductoDespensa p : productos) {
            if (p.getAlimento() != null) {
                ingredientesDespensa.add(p.getAlimento().getNombre());
            }
        }

        Map<String, Object> recetaMap;

        if (intoleranciaId != null) {
            IntoleranciaUsuario intolerancia = intoleranciaRepository.findById(intoleranciaId)
                    .orElseThrow(() -> new Exception("Intolerancia no encontrada"));

            List<Map<String, Object>> motivos = new ArrayList<>();
            for (MotivoRechazo m : intolerancia.getMotivos()) {
                motivos.add(Map.of("tipo", m.getTipo().name(), "intensidad", m.getIntensidad()));
            }

            recetaMap = iaService.generarRecetaConDespensaYAversion(
                    descripcion,
                    ingredientesDespensa,
                    intolerancia.getAlimento().getNombre(),
                    intolerancia.getNivelRechazo(),
                    motivos
            );
        } else {
            recetaMap = iaService.generarRecetaConDespensa(descripcion, ingredientesDespensa);
        }

        Receta receta = construirYPersistirReceta(recetaMap);
        return recetaToDTO(receta);
    }

    private Receta construirYPersistirReceta(Map<String, Object> recetaMap) {
        Receta receta = new Receta();
        receta.setTitulo((String) recetaMap.get("titulo"));
        receta.setDescripcion((String) recetaMap.get("descripcion"));
        receta.setInstrucciones((String) recetaMap.get("instrucciones"));
        receta.setTiempoPreparacion(toInt(recetaMap.get("tiempoPreparacion")));
        receta.setTiempoCoccion(toInt(recetaMap.get("tiempoCoccion")));
        receta.setDificultad(parseDificultad((String) recetaMap.get("dificultad")));
        receta.setGeneradaPorIa(true);

        recetaRepository.save(receta);

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> ingredientes = (List<Map<String, Object>>) recetaMap.get("ingredientes");

        if (ingredientes != null) {
            for (Map<String, Object> ingMap : ingredientes) {
                String nombreAlimento = (String) ingMap.get("nombre");
                String categoria = (String) ingMap.get("categoria");

                Alimento alimento = buscarOCrearAlimento(nombreAlimento, categoria != null ? categoria : "Otros");

                RecetaAlimento ra = new RecetaAlimento();
                ra.setReceta(receta);
                ra.setAlimento(alimento);
                ra.setCantidad(toBigDecimal(ingMap.get("cantidad")));
                ra.setUnidadMedida((String) ingMap.getOrDefault("unidadMedida", "g"));
                ra.setRol(parseRol((String) ingMap.get("rol")));
                ra.setMetodoPreparacion(parseMetodo((String) ingMap.get("metodoPreparacion")));
                ra.setOculto(false);
                ra.setCantidadMinima(toBigDecimal(ingMap.get("cantidad")).multiply(new BigDecimal("0.3")));
                ra.setDescripcionNutricional((String) ingMap.get("descripcionEdamam"));

                receta.getIngredientes().add(ra);
            }
        }

        receta.setImagenUrl(resolverImagen(receta));
        calcularYAplicarNutricion(receta);

        return recetaRepository.save(receta);
    }

    /**
     * Calcula calorias y macronutrientes totales de la receta delegando en
     * Gemini (sustituye a Edamam por agotamiento de cuota). Construye un
     * listado de ingredientes en espanol con cantidad y unidad para que el
     * modelo pueda estimar el aporte agregado.
     */
    public void calcularYAplicarNutricion(Receta receta) {
        if (receta.getIngredientes() == null || receta.getIngredientes().isEmpty()) return;

        // Construye descripciones tipo "200 g pechuga de pollo" para cada ingrediente.
        List<String> texto = new ArrayList<>();
        for (RecetaAlimento ra : receta.getIngredientes()) {
            if (ra.getAlimento() == null) continue;
            String unidad = ra.getUnidadMedida() != null ? ra.getUnidadMedida() : "g";
            String cantidad = ra.getCantidad() != null
                    ? ra.getCantidad().stripTrailingZeros().toPlainString()
                    : "1";
            texto.add(cantidad + " " + unidad + " " + ra.getAlimento().getNombre());
        }

        try {
            Map<String, Object> nut = iaService.analizarNutricion(receta.getTitulo(), texto);
            if (nut == null) return;
            receta.setCaloriasTotal(((Number) nut.get("calorias")).doubleValue());
            receta.setProteinasTotal(((Number) nut.get("proteinas")).doubleValue());
            receta.setHidratosTotal(((Number) nut.get("hidratos")).doubleValue());
            receta.setGrasasTotal(((Number) nut.get("grasas")).doubleValue());
        } catch (Exception e) {
            System.err.println("[RecetaGeneradorService] Error al calcular nutricion via Gemini: " + e.getMessage());
        }
    }

    private RecetaDTO recetaToDTO(Receta r) {
        RecetaDTO dto = new RecetaDTO();
        dto.setId(r.getId());
        dto.setTitulo(r.getTitulo());
        dto.setDescripcion(r.getDescripcion());
        dto.setInstrucciones(r.getInstrucciones());
        dto.setTiempoPreparacion(r.getTiempoPreparacion());
        dto.setTiempoCoccion(r.getTiempoCoccion());
        dto.setDificultad(r.getDificultad() != null ? r.getDificultad().name() : null);
        dto.setImagenUrl(r.getImagenUrl());
        dto.setGeneradaPorIa(r.isGeneradaPorIa());
        dto.setCaloriasTotal(r.getCaloriasTotal());
        dto.setProteinasTotal(r.getProteinasTotal());
        dto.setHidratosTotal(r.getHidratosTotal());
        dto.setGrasasTotal(r.getGrasasTotal());
        dto.setCreatedAt(r.getCreatedAt());

        List<IngredienteDTO> ingredientesDTO = new ArrayList<>();
        if (r.getIngredientes() != null) {
            for (RecetaAlimento ra : r.getIngredientes()) {
                ingredientesDTO.add(ingredienteToDTO(ra));
            }
        }
        dto.setIngredientes(ingredientesDTO);

        return dto;
    }

    private IngredienteDTO ingredienteToDTO(RecetaAlimento ra) {
        IngredienteDTO dto = new IngredienteDTO();
        dto.setId(ra.getId());
        dto.setCantidad(ra.getCantidad());
        dto.setUnidadMedida(ra.getUnidadMedida());
        dto.setRol(ra.getRol() != null ? ra.getRol().name() : null);
        dto.setMetodoPreparacion(ra.getMetodoPreparacion() != null ? ra.getMetodoPreparacion().name() : null);
        dto.setOculto(ra.isOculto());

        if (ra.getAlimento() != null) {
            dto.setAlimento(alimentoToDTO(ra.getAlimento()));
        }

        return dto;
    }

    private AlimentoDTO alimentoToDTO(Alimento a) {
        AlimentoDTO dto = new AlimentoDTO();
        dto.setId(a.getId());
        dto.setNombre(a.getNombre());
        dto.setCategoria(a.getCategoria());
        dto.setImagenUrl(a.getImagenUrl());
        return dto;
    }

    private Alimento buscarOCrearAlimento(String nombre, String categoria) {
        return alimentoRepository.findByNombreIgnoreCase(nombre)
                .orElseGet(() -> alimentoRepository.save(new Alimento(nombre, categoria)));
    }

    private int toInt(Object valor) {
        if (valor instanceof Integer) return (Integer) valor;
        if (valor instanceof Number) return ((Number) valor).intValue();
        if (valor instanceof String) return Integer.parseInt((String) valor);
        return 0;
    }

    private BigDecimal toBigDecimal(Object valor) {
        if (valor instanceof Number) return new BigDecimal(valor.toString());
        if (valor instanceof String) return new BigDecimal((String) valor);
        return BigDecimal.ONE;
    }

    private DificultadReceta parseDificultad(String valor) {
        try { return DificultadReceta.valueOf(valor); }
        catch (Exception e) { return DificultadReceta.MEDIA; }
    }

    private RolIngrediente parseRol(String valor) {
        try { return RolIngrediente.valueOf(valor); }
        catch (Exception e) { return RolIngrediente.SECUNDARIO; }
    }

    private MetodoPreparacion parseMetodo(String valor) {
        try { return MetodoPreparacion.valueOf(valor); }
        catch (Exception e) { return MetodoPreparacion.CRUDO; }
    }
}
