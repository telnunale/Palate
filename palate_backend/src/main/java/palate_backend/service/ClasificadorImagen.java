package palate_backend.service;

import palate_backend.config.ImagenesPool;
import palate_backend.config.ImagenesPool.Categoria;
import palate_backend.enums.MetodoPreparacion;
import palate_backend.enums.RolIngrediente;
import palate_backend.model.Receta;
import palate_backend.model.RecetaAlimento;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.List;
import java.util.Map;

/**
 * Clasifica una receta en una de las categorias visuales del pool y
 * devuelve una URL de imagen. Aplica keyword del titulo, alimento
 * protagonista + metodo y fallback generico.
 */
@Service
public class ClasificadorImagen {

    private final ImagenesPool imagenesPool;

    @Autowired
    public ClasificadorImagen(ImagenesPool imagenesPool) {
        this.imagenesPool = imagenesPool;
    }

    public String elegirImagen(Receta receta) {
        Categoria categoria = clasificar(receta);
        return imagenesPool.elegir(categoria, receta.getTitulo());
    }

    Categoria clasificar(Receta receta) {
        String texto = normalizar(
                (receta.getTitulo() != null ? receta.getTitulo() : "") + " " +
                (receta.getDescripcion() != null ? receta.getDescripcion() : "")
        );

        Categoria porKeyword = clasificarPorKeyword(texto);
        if (porKeyword != null) return porKeyword;

        RecetaAlimento protagonista = buscarProtagonista(receta);
        if (protagonista != null) {
            Categoria porProtagonista = clasificarPorProtagonista(protagonista);
            if (porProtagonista != null) return porProtagonista;
        }

        if (protagonista != null && protagonista.getMetodoPreparacion() != null) {
            Categoria porMetodo = clasificarPorMetodo(protagonista.getMetodoPreparacion());
            if (porMetodo != null) return porMetodo;
        }

        return Categoria.BOWL_GENERICO;
    }

    private static final Map<String, Categoria> KEYWORDS = Map.ofEntries(
            Map.entry("tarta", Categoria.POSTRE),
            Map.entry("bizcocho", Categoria.POSTRE),
            Map.entry("flan", Categoria.POSTRE),
            Map.entry("mousse", Categoria.POSTRE),
            Map.entry("helado", Categoria.POSTRE),
            Map.entry("galleta", Categoria.POSTRE),
            Map.entry("brownie", Categoria.POSTRE),
            Map.entry("crepe", Categoria.POSTRE),
            Map.entry("tiramisu", Categoria.POSTRE),
            Map.entry("postre", Categoria.POSTRE),
            Map.entry("pizza", Categoria.PAN_MASA),
            Map.entry("focaccia", Categoria.PAN_MASA),
            Map.entry("empanada", Categoria.PAN_MASA),
            Map.entry("calzone", Categoria.PAN_MASA),
            Map.entry("hojaldre", Categoria.PAN_MASA),
            Map.entry("masa", Categoria.PAN_MASA),
            Map.entry("lasana", Categoria.HORNO_GRATEN),
            Map.entry("canelones", Categoria.HORNO_GRATEN),
            Map.entry("gratin", Categoria.HORNO_GRATEN),
            Map.entry("graten", Categoria.HORNO_GRATEN),
            Map.entry("pastel de", Categoria.HORNO_GRATEN),
            Map.entry("espagueti", Categoria.PASTA),
            Map.entry("spaghetti", Categoria.PASTA),
            Map.entry("macarron", Categoria.PASTA),
            Map.entry("tallarin", Categoria.PASTA),
            Map.entry("ravioli", Categoria.PASTA),
            Map.entry("fettuccine", Categoria.PASTA),
            Map.entry("penne", Categoria.PASTA),
            Map.entry("noquis", Categoria.PASTA),
            Map.entry("pasta", Categoria.PASTA),
            Map.entry("carbonara", Categoria.PASTA),
            Map.entry("bolonesa", Categoria.PASTA),
            Map.entry("bolognesa", Categoria.PASTA),
            Map.entry("paella", Categoria.ARROZ),
            Map.entry("risotto", Categoria.ARROZ),
            Map.entry("arroz", Categoria.ARROZ),
            Map.entry("sopa", Categoria.SOPA_CREMA),
            Map.entry("crema de", Categoria.SOPA_CREMA),
            Map.entry("caldo", Categoria.SOPA_CREMA),
            Map.entry("gazpacho", Categoria.SOPA_CREMA),
            Map.entry("salmorejo", Categoria.SOPA_CREMA),
            Map.entry("vichyssoise", Categoria.SOPA_CREMA),
            Map.entry("ensalada", Categoria.ENSALADA),
            Map.entry("albondiga", Categoria.CARNE_GUISO),
            Map.entry("estofado", Categoria.CARNE_GUISO),
            Map.entry("guiso", Categoria.CARNE_GUISO),
            Map.entry("ragu", Categoria.CARNE_GUISO),
            Map.entry("ragout", Categoria.CARNE_GUISO),
            Map.entry("goulash", Categoria.CARNE_GUISO),
            Map.entry("carrillera", Categoria.CARNE_GUISO),
            Map.entry("rabo de", Categoria.CARNE_GUISO),
            Map.entry("carne con", Categoria.CARNE_GUISO),
            Map.entry("filete", Categoria.CARNE_PLANCHA),
            Map.entry("entrecot", Categoria.CARNE_PLANCHA),
            Map.entry("solomillo", Categoria.CARNE_PLANCHA),
            Map.entry("churrasco", Categoria.CARNE_PLANCHA),
            Map.entry("chuleta", Categoria.CARNE_PLANCHA),
            Map.entry("hamburguesa", Categoria.CARNE_PLANCHA),
            Map.entry("pollo asado", Categoria.CARNE_PLANCHA),
            Map.entry("pollo a la plancha", Categoria.CARNE_PLANCHA),
            Map.entry("brocheta", Categoria.CARNE_PLANCHA),
            Map.entry("salmon", Categoria.PESCADO),
            Map.entry("merluza", Categoria.PESCADO),
            Map.entry("bacalao", Categoria.PESCADO),
            Map.entry("atun", Categoria.PESCADO),
            Map.entry("dorada", Categoria.PESCADO),
            Map.entry("lubina", Categoria.PESCADO),
            Map.entry("trucha", Categoria.PESCADO),
            Map.entry("pescado", Categoria.PESCADO),
            Map.entry("marisco", Categoria.PESCADO),
            Map.entry("gambas", Categoria.PESCADO),
            Map.entry("lenteja", Categoria.LEGUMBRE),
            Map.entry("garbanzo", Categoria.LEGUMBRE),
            Map.entry("alubia", Categoria.LEGUMBRE),
            Map.entry("judia", Categoria.LEGUMBRE),
            Map.entry("hummus", Categoria.LEGUMBRE),
            Map.entry("fabada", Categoria.LEGUMBRE),
            Map.entry("cocido", Categoria.LEGUMBRE),
            Map.entry("tortilla", Categoria.HUEVO_TORTILLA),
            Map.entry("revuelto", Categoria.HUEVO_TORTILLA),
            Map.entry("huevo", Categoria.HUEVO_TORTILLA),
            Map.entry("frittata", Categoria.HUEVO_TORTILLA),
            Map.entry("quiche", Categoria.HUEVO_TORTILLA),
            Map.entry("salteado", Categoria.VERDURA_SALTEADA),
            Map.entry("wok", Categoria.VERDURA_SALTEADA),
            Map.entry("verduras", Categoria.VERDURA_SALTEADA),
            Map.entry("parrillada de verdura", Categoria.VERDURA_SALTEADA)
    );

    private Categoria clasificarPorKeyword(String textoNormalizado) {
        for (Map.Entry<String, Categoria> entry : KEYWORDS.entrySet()) {
            if (textoNormalizado.contains(entry.getKey())) {
                return entry.getValue();
            }
        }
        return null;
    }

    private Categoria clasificarPorProtagonista(RecetaAlimento ra) {
        String nombre = normalizar(ra.getAlimento() != null ? ra.getAlimento().getNombre() : "");
        String categoriaAlimento = normalizar(ra.getAlimento() != null ? ra.getAlimento().getCategoria() : "");
        MetodoPreparacion metodo = ra.getMetodoPreparacion();

        if (categoriaAlimento.contains("pescado") || categoriaAlimento.contains("marisco")) {
            return Categoria.PESCADO;
        }

        if (categoriaAlimento.contains("carne") || nombre.contains("ternera")
                || nombre.contains("cerdo") || nombre.contains("cordero")
                || nombre.contains("pollo")) {
            if (metodo == MetodoPreparacion.EN_SALSA || metodo == MetodoPreparacion.MARINADO) {
                return Categoria.CARNE_GUISO;
            }
            if (metodo == MetodoPreparacion.HORNEADO) {
                return Categoria.HORNO_GRATEN;
            }
            return Categoria.CARNE_PLANCHA;
        }

        if (categoriaAlimento.contains("legumbre")) {
            return Categoria.LEGUMBRE;
        }

        if (categoriaAlimento.contains("verdura") || categoriaAlimento.contains("hortaliza")) {
            return Categoria.VERDURA_SALTEADA;
        }

        return null;
    }

    private Categoria clasificarPorMetodo(MetodoPreparacion metodo) {
        return switch (metodo) {
            case TRITURADO -> Categoria.SOPA_CREMA;
            case EN_SALSA -> Categoria.CARNE_GUISO;
            case HORNEADO -> Categoria.HORNO_GRATEN;
            case CRUDO -> Categoria.ENSALADA;
            case FRITO -> Categoria.CARNE_PLANCHA;
            case MARINADO -> Categoria.CARNE_GUISO;
            case HERVIDO -> Categoria.SOPA_CREMA;
            case AL_VAPOR -> Categoria.VERDURA_SALTEADA;
        };
    }

    private RecetaAlimento buscarProtagonista(Receta receta) {
        List<RecetaAlimento> ingredientes = receta.getIngredientes();
        if (ingredientes == null || ingredientes.isEmpty()) return null;
        for (RecetaAlimento ra : ingredientes) {
            if (ra.getRol() == RolIngrediente.PROTAGONISTA) return ra;
        }
        return ingredientes.get(0);
    }

    private String normalizar(String texto) {
        if (texto == null) return "";
        String sinTildes = Normalizer.normalize(texto, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        return sinTildes.toLowerCase();
    }
}
