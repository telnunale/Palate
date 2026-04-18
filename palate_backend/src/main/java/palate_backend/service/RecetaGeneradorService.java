package palate_backend.service;

import palate_backend.model.Alimento;
import palate_backend.model.Receta;
import palate_backend.model.RecetaAlimento;
import palate_backend.enums.DificultadReceta;
import palate_backend.enums.MetodoPreparacion;
import palate_backend.enums.RolIngrediente;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
public class RecetaGeneradorService {

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private IAService iaService;

    @Transactional
    public Receta generarYGuardar(String descripcion) throws Exception {

        // 1. Buscar en caché primero
        Receta recetaCache = buscarEnCache(descripcion);
        if (recetaCache != null) {
            return recetaCache;
        }

        // 2. Generar con IA
        Map<String, Object> recetaMap = iaService.generarReceta(descripcion);

        // 3. Crear la entidad Receta
        Receta receta = new Receta();
        receta.setTitulo((String) recetaMap.get("titulo"));
        receta.setDescripcion((String) recetaMap.get("descripcion"));
        receta.setInstrucciones((String) recetaMap.get("instrucciones"));
        receta.setTiempoPreparacion(toInt(recetaMap.get("tiempoPreparacion")));
        receta.setTiempoCoccion(toInt(recetaMap.get("tiempoCoccion")));
        receta.setDificultad(parseDificultad((String) recetaMap.get("dificultad")));
        receta.setGeneradaPorIa(true);

        em.persist(receta);

        // 4. Procesar ingredientes
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> ingredientes = (List<Map<String, Object>>) recetaMap.get("ingredientes");

        if (ingredientes != null) {
            for (Map<String, Object> ingMap : ingredientes) {
                String nombreAlimento = (String) ingMap.get("nombre");
                String categoria = (String) ingMap.get("categoria");

                // Buscar o crear el alimento
                Alimento alimento = buscarOCrearAlimento(nombreAlimento, categoria != null ? categoria : "Otros");

                // Crear la relación RecetaAlimento
                RecetaAlimento ra = new RecetaAlimento();
                ra.setReceta(receta);
                ra.setAlimento(alimento);
                ra.setCantidad(toBigDecimal(ingMap.get("cantidad")));
                ra.setUnidadMedida((String) ingMap.getOrDefault("unidadMedida", "g"));
                ra.setRol(parseRol((String) ingMap.get("rol")));
                ra.setMetodoPreparacion(parseMetodo((String) ingMap.get("metodoPreparacion")));
                ra.setOculto(false);
                ra.setCantidadMinima(toBigDecimal(ingMap.get("cantidad")).multiply(new BigDecimal("0.3")));

                em.persist(ra);
                receta.getIngredientes().add(ra);
            }
        }

        return receta;
    }

    private Receta buscarEnCache(String descripcion) {
        String jpql = "SELECT r FROM Receta r WHERE LOWER(r.titulo) LIKE LOWER(:busqueda) " +
                "OR LOWER(r.descripcion) LIKE LOWER(:busqueda)";
        TypedQuery<Receta> query = em.createQuery(jpql, Receta.class);
        query.setParameter("busqueda", "%" + descripcion.toLowerCase() + "%");
        query.setMaxResults(1);
        List<Receta> resultados = query.getResultList();
        return resultados.isEmpty() ? null : resultados.get(0);
    }

    private Alimento buscarOCrearAlimento(String nombre, String categoria) {
        String jpql = "SELECT a FROM Alimento a WHERE LOWER(a.nombre) = LOWER(:nombre)";
        TypedQuery<Alimento> query = em.createQuery(jpql, Alimento.class);
        query.setParameter("nombre", nombre);
        List<Alimento> resultados = query.getResultList();

        if (!resultados.isEmpty()) {
            return resultados.get(0);
        }

        Alimento nuevo = new Alimento(nombre, categoria);
        em.persist(nuevo);
        return nuevo;
    }

    // ==================== UTILIDADES DE PARSEO ====================

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
        try {
            return DificultadReceta.valueOf(valor);
        } catch (Exception e) {
            return DificultadReceta.MEDIA;
        }
    }

    private RolIngrediente parseRol(String valor) {
        try {
            return RolIngrediente.valueOf(valor);
        } catch (Exception e) {
            return RolIngrediente.SECUNDARIO;
        }
    }

    private MetodoPreparacion parseMetodo(String valor) {
        try {
            return MetodoPreparacion.valueOf(valor);
        } catch (Exception e) {
            return MetodoPreparacion.CRUDO;
        }
    }
}