package palate_backend.service;

import palate_backend.dto.AlimentoDTO;
import palate_backend.dto.IngredienteDTO;
import palate_backend.dto.RecetaRecomendadaDTO;
import palate_backend.enums.MetodoPreparacion;
import palate_backend.enums.RolIngrediente;
import palate_backend.enums.TipoMotivoRechazo;
import palate_backend.model.*;
import palate_backend.repository.IntoleranciaUsuarioRepository;
import palate_backend.repository.RecetaRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Motor de recomendacion en dos capas: capa 1 filtra recetas incompatibles
 * con las aversiones del usuario y capa 2 puntua las supervivientes segun
 * el metodo de preparacion de los ingredientes problematicos.
 */
@Service
public class RecomendacionServiceImpl implements RecomendacionService {

    private static final int SCORE_INICIAL = 100;
    private static final int PENALIZACION_POR_NIVEL = 3;
    private static final int BONO_METODO_COMPATIBLE = 5;
    private static final int PENALIZACION_METODO_CONTRAINDICADO = 8;
    private static final int MAX_RECOMENDACIONES = 10;

    private final RecetaRepository recetaRepository;
    private final IntoleranciaUsuarioRepository intoleranciaRepository;

    private static final Map<TipoMotivoRechazo, List<MetodoPreparacion>> METODOS_COMPATIBLES = new HashMap<>();
    static {
        METODOS_COMPATIBLES.put(TipoMotivoRechazo.TEXTURA, List.of(
                MetodoPreparacion.TRITURADO, MetodoPreparacion.EN_SALSA, MetodoPreparacion.FRITO));
        METODOS_COMPATIBLES.put(TipoMotivoRechazo.SABOR, List.of(
                MetodoPreparacion.EN_SALSA, MetodoPreparacion.MARINADO, MetodoPreparacion.HORNEADO));
        METODOS_COMPATIBLES.put(TipoMotivoRechazo.OLOR, List.of(
                MetodoPreparacion.HORNEADO, MetodoPreparacion.FRITO, MetodoPreparacion.MARINADO));
        METODOS_COMPATIBLES.put(TipoMotivoRechazo.COLOR, List.of(
                MetodoPreparacion.TRITURADO, MetodoPreparacion.EN_SALSA, MetodoPreparacion.HORNEADO));
    }

    private static final Map<TipoMotivoRechazo, List<MetodoPreparacion>> METODOS_CONTRAINDICADOS = new HashMap<>();
    static {
        METODOS_CONTRAINDICADOS.put(TipoMotivoRechazo.TEXTURA, List.of(
                MetodoPreparacion.CRUDO, MetodoPreparacion.AL_VAPOR, MetodoPreparacion.HERVIDO));
        METODOS_CONTRAINDICADOS.put(TipoMotivoRechazo.SABOR, List.of(
                MetodoPreparacion.CRUDO, MetodoPreparacion.HERVIDO));
        METODOS_CONTRAINDICADOS.put(TipoMotivoRechazo.OLOR, List.of(
                MetodoPreparacion.CRUDO, MetodoPreparacion.AL_VAPOR));
        METODOS_CONTRAINDICADOS.put(TipoMotivoRechazo.COLOR, List.of(
                MetodoPreparacion.CRUDO));
    }

    @Autowired
    public RecomendacionServiceImpl(RecetaRepository recetaRepository,
                                    IntoleranciaUsuarioRepository intoleranciaRepository) {
        this.recetaRepository = recetaRepository;
        this.intoleranciaRepository = intoleranciaRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<RecetaRecomendadaDTO> obtenerRecomendaciones(Long usuarioId) {
        List<IntoleranciaUsuario> aversionesActivas = intoleranciaRepository
                .findByUsuarioId(usuarioId)
                .stream()
                .filter(a -> !a.isSuperada())
                .toList();

        List<Receta> recetas = recetaRepository.findAll();
        List<RecetaRecomendadaDTO> resultado = new ArrayList<>();

        for (Receta receta : recetas) {
            // Capa 1: filtrado eliminatorio
            if (!aplicarCapa1Filtrado(receta, aversionesActivas)) {
                continue;
            }

            // Capa 2: calculo de puntuacion y motivo descriptivo
            int score = calcularScoreCapa2(receta, aversionesActivas);
            String motivo = generarMotivoRecomendacion(receta, aversionesActivas, score);

            resultado.add(toDTO(receta, score, motivo));
        }

        resultado.sort(Comparator.comparingInt(RecetaRecomendadaDTO::getScore).reversed());
        if (resultado.size() > MAX_RECOMENDACIONES) {
            return resultado.subList(0, MAX_RECOMENDACIONES);
        }
        return resultado;
    }

    /**
     * Capa 1: descarta una receta si contiene un ingrediente con aversion
     * en una combinacion de nivel/rol incompatible.
     * Rechazo 7-10 + rol PROTAGONISTA o SECUNDARIO -> incompatible.
     * Rechazo 4-6 + rol PROTAGONISTA -> incompatible.
     */
    private boolean aplicarCapa1Filtrado(Receta receta, List<IntoleranciaUsuario> aversiones) {
        if (aversiones.isEmpty()) {
            return true;
        }

        for (RecetaAlimento ingrediente : receta.getIngredientes()) {
            IntoleranciaUsuario aversion = buscarAversionDeIngrediente(ingrediente, aversiones);
            if (aversion == null) continue;

            int nivel = aversion.getNivelRechazo();
            RolIngrediente rol = ingrediente.getRol();

            if (nivel >= 7 && (rol == RolIngrediente.PROTAGONISTA || rol == RolIngrediente.SECUNDARIO)) {
                return false;
            }
            if (nivel >= 4 && nivel <= 6 && rol == RolIngrediente.PROTAGONISTA) {
                return false;
            }
        }
        return true;
    }

    /**
     * Capa 2: calcula la puntuacion segun nivel de rechazo de los
     * ingredientes problematicos y su metodo de preparacion. Score [0, 100].
     */
    private int calcularScoreCapa2(Receta receta, List<IntoleranciaUsuario> aversiones) {
        int score = SCORE_INICIAL;

        for (RecetaAlimento ingrediente : receta.getIngredientes()) {
            IntoleranciaUsuario aversion = buscarAversionDeIngrediente(ingrediente, aversiones);
            if (aversion == null) continue;

            score -= aversion.getNivelRechazo() * PENALIZACION_POR_NIVEL;

            MetodoPreparacion metodo = ingrediente.getMetodoPreparacion();
            if (metodo == null) continue;

            for (MotivoRechazo motivo : aversion.getMotivos()) {
                if (esMetodoCompatible(metodo, motivo.getTipo())) {
                    score += BONO_METODO_COMPATIBLE;
                } else if (esMetodoContraindicado(metodo, motivo.getTipo())) {
                    score -= PENALIZACION_METODO_CONTRAINDICADO;
                }
            }
        }

        if (score < 0) score = 0;
        if (score > 100) score = 100;
        return score;
    }

    private String generarMotivoRecomendacion(Receta receta,
                                              List<IntoleranciaUsuario> aversiones,
                                              int score) {
        boolean tieneAversionAfectada = false;
        for (RecetaAlimento ingrediente : receta.getIngredientes()) {
            if (buscarAversionDeIngrediente(ingrediente, aversiones) != null) {
                tieneAversionAfectada = true;
                break;
            }
        }

        if (!tieneAversionAfectada) {
            return "Receta compatible con tu perfil";
        }
        if (score >= 80) {
            return "Excelente encaje con tu perfil sensorial";
        }
        if (score >= 60) {
            return "Buen encaje, ingredientes preparados de forma favorable";
        }
        return "Encaje moderado, util para trabajar tu progreso";
    }

    private IntoleranciaUsuario buscarAversionDeIngrediente(RecetaAlimento ingrediente,
                                                            List<IntoleranciaUsuario> aversiones) {
        if (ingrediente.getAlimento() == null) return null;
        Long alimentoId = ingrediente.getAlimento().getId();
        for (IntoleranciaUsuario aversion : aversiones) {
            if (aversion.getAlimento() != null
                    && aversion.getAlimento().getId().equals(alimentoId)) {
                return aversion;
            }
        }
        return null;
    }

    private boolean esMetodoCompatible(MetodoPreparacion metodo, TipoMotivoRechazo motivo) {
        List<MetodoPreparacion> compatibles = METODOS_COMPATIBLES.get(motivo);
        return compatibles != null && compatibles.contains(metodo);
    }

    private boolean esMetodoContraindicado(MetodoPreparacion metodo, TipoMotivoRechazo motivo) {
        List<MetodoPreparacion> contraindicados = METODOS_CONTRAINDICADOS.get(motivo);
        return contraindicados != null && contraindicados.contains(metodo);
    }

    private RecetaRecomendadaDTO toDTO(Receta r, int score, String motivo) {
        RecetaRecomendadaDTO dto = new RecetaRecomendadaDTO();
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
        dto.setScore(score);
        dto.setMotivoRecomendacion(motivo);

        List<IngredienteDTO> ingredientesDTO = new ArrayList<>();
        if (r.getIngredientes() != null) {
            for (RecetaAlimento ra : r.getIngredientes()) {
                IngredienteDTO ingDTO = new IngredienteDTO();
                ingDTO.setId(ra.getId());
                ingDTO.setCantidad(ra.getCantidad());
                ingDTO.setUnidadMedida(ra.getUnidadMedida());
                ingDTO.setRol(ra.getRol() != null ? ra.getRol().name() : null);
                ingDTO.setMetodoPreparacion(ra.getMetodoPreparacion() != null
                        ? ra.getMetodoPreparacion().name() : null);
                ingDTO.setOculto(ra.isOculto());
                if (ra.getAlimento() != null) {
                    AlimentoDTO al = new AlimentoDTO();
                    al.setId(ra.getAlimento().getId());
                    al.setNombre(ra.getAlimento().getNombre());
                    al.setCategoria(ra.getAlimento().getCategoria());
                    al.setImagenUrl(ra.getAlimento().getImagenUrl());
                    ingDTO.setAlimento(al);
                }
                ingredientesDTO.add(ingDTO);
            }
        }
        dto.setIngredientes(ingredientesDTO);
        return dto;
    }
}
