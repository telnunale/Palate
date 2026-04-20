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

    @Autowired
    public RecetaGeneradorService(RecetaRepository recetaRepository,
                                  AlimentoRepository alimentoRepository,
                                  IAService iaService,
                                  IntoleranciaUsuarioRepository intoleranciaRepository) {
        this.recetaRepository = recetaRepository;
        this.alimentoRepository = alimentoRepository;
        this.iaService = iaService;
        this.intoleranciaRepository = intoleranciaRepository;
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
        List<Receta> cache = recetaRepository.buscarEnCache("%" + descripcion.toLowerCase() + "%");
        if (!cache.isEmpty()) {
            return recetaToDTO(cache.get(0));
        }

        Map<String, Object> recetaMap = iaService.generarReceta(descripcion);
        Receta receta = construirYPersistirReceta(recetaMap);
        return recetaToDTO(receta);
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

                receta.getIngredientes().add(ra);
            }
        }

        return recetaRepository.save(receta);
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
