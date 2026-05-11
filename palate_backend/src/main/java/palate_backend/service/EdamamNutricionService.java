package palate_backend.service;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Cliente Edamam Nutrition Analysis. Envia la lista de ingredientes en
 * texto libre y obtiene calorias y macronutrientes totales de la receta.
 */
@Service
public class EdamamNutricionService {

    private static final String ENDPOINT = "https://api.edamam.com/api/nutrition-details";

    private final String appId;
    private final String appKey;
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public EdamamNutricionService(
            @Value("${palate.edamam.app-id:}") String appId,
            @Value("${palate.edamam.app-key:}") String appKey) {
        this.appId = appId;
        this.appKey = appKey;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(8))
                .build();
    }

    public Optional<NutricionResultado> analizar(String titulo, List<String> ingredientesTextoLibre) {
        if (appId == null || appId.isBlank() || appKey == null || appKey.isBlank()) {
            return Optional.empty();
        }
        if (ingredientesTextoLibre == null || ingredientesTextoLibre.isEmpty()) {
            return Optional.empty();
        }

        try {
            String body = objectMapper.writeValueAsString(Map.of(
                    "title", titulo != null ? titulo : "Receta",
                    "ingr", ingredientesTextoLibre
            ));

            String url = ENDPOINT + "?app_id=" + appId + "&app_key=" + appKey;

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(15))
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = httpClient.send(
                    request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                System.err.println("[Edamam] Status " + response.statusCode()
                        + " body=" + response.body());
                return Optional.empty();
            }

            JsonNode root = objectMapper.readTree(response.body());
            double calorias = root.path("calories").asDouble(0);
            JsonNode nutrientes = root.path("totalNutrients");
            double proteinas = nutrientes.path("PROCNT").path("quantity").asDouble(0);
            double hidratos = nutrientes.path("CHOCDF").path("quantity").asDouble(0);
            double grasas = nutrientes.path("FAT").path("quantity").asDouble(0);

            if (calorias <= 0) return Optional.empty();
            return Optional.of(new NutricionResultado(calorias, proteinas, hidratos, grasas));

        } catch (Exception e) {
            System.err.println("[Edamam] Error consultando API: " + e.getMessage());
            return Optional.empty();
        }
    }

    public record NutricionResultado(double calorias, double proteinas, double hidratos, double grasas) {}

    private static final Map<String, String> TRADUCCION = Map.ofEntries(
            Map.entry("aceite de oliva", "olive oil"),
            Map.entry("ajo en polvo", "garlic powder"),
            Map.entry("ajo", "garlic"),
            Map.entry("albahaca", "basil"),
            Map.entry("arroz arborio", "arborio rice"),
            Map.entry("arroz basmati", "basmati rice"),
            Map.entry("arroz", "rice"),
            Map.entry("atun en lata", "canned tuna"),
            Map.entry("bacalao desalado", "cod"),
            Map.entry("bechamel", "bechamel sauce"),
            Map.entry("brandy", "brandy"),
            Map.entry("brocoli", "broccoli"),
            Map.entry("caldo de carne", "beef broth"),
            Map.entry("caldo de pollo", "chicken broth"),
            Map.entry("caldo de verduras", "vegetable broth"),
            Map.entry("carne picada", "ground beef"),
            Map.entry("cebolla en polvo", "onion powder"),
            Map.entry("cebolla", "onion"),
            Map.entry("champinones", "mushrooms"),
            Map.entry("coliflor", "cauliflower"),
            Map.entry("curry en polvo", "curry powder"),
            Map.entry("espinacas", "spinach"),
            Map.entry("garbanzos cocidos", "cooked chickpeas"),
            Map.entry("harina", "flour"),
            Map.entry("higado de pollo", "chicken liver"),
            Map.entry("higado de ternera", "beef liver"),
            Map.entry("huevo", "egg"),
            Map.entry("jengibre", "ginger"),
            Map.entry("leche de coco", "coconut milk"),
            Map.entry("leche", "milk"),
            Map.entry("limon", "lemon"),
            Map.entry("mantequilla", "butter"),
            Map.entry("masa de pizza", "pizza dough"),
            Map.entry("masa quebrada", "shortcrust pastry"),
            Map.entry("merluza", "hake"),
            Map.entry("miel", "honey"),
            Map.entry("mostaza", "mustard"),
            Map.entry("mozzarella", "mozzarella cheese"),
            Map.entry("nata para cocinar", "cooking cream"),
            Map.entry("nuez moscada", "nutmeg"),
            Map.entry("oregano", "oregano"),
            Map.entry("pan de hamburguesa", "burger bun"),
            Map.entry("pan rallado", "breadcrumbs"),
            Map.entry("pan tostado", "toasted bread"),
            Map.entry("paprika", "paprika"),
            Map.entry("pasta para lasana", "lasagna sheets"),
            Map.entry("pasta", "pasta"),
            Map.entry("patata", "potato"),
            Map.entry("pechuga de pollo", "chicken breast"),
            Map.entry("pepino", "cucumber"),
            Map.entry("perejil", "parsley"),
            Map.entry("pesto", "pesto sauce"),
            Map.entry("pimenton", "paprika"),
            Map.entry("pimiento verde", "green bell pepper"),
            Map.entry("platano", "banana"),
            Map.entry("queso cheddar", "cheddar cheese"),
            Map.entry("queso crema", "cream cheese"),
            Map.entry("queso emmental", "emmental cheese"),
            Map.entry("queso gruyere", "gruyere cheese"),
            Map.entry("queso mozzarella", "mozzarella cheese"),
            Map.entry("queso parmesano", "parmesan cheese"),
            Map.entry("queso rallado", "grated cheese"),
            Map.entry("ricotta", "ricotta cheese"),
            Map.entry("salmon", "salmon"),
            Map.entry("salsa barbacoa", "barbecue sauce"),
            Map.entry("salsa de soja", "soy sauce"),
            Map.entry("tahini", "tahini"),
            Map.entry("tomate triturado", "crushed tomato"),
            Map.entry("tomate", "tomato"),
            Map.entry("vinagre de jerez", "sherry vinegar"),
            Map.entry("vino blanco", "white wine"),
            Map.entry("vino de jerez", "sherry wine"),
            Map.entry("zanahoria", "carrot")
    );

    public String construirDescripcionFallback(String nombreAlimento, String cantidad, String unidad) {
        String clave = nombreAlimento.toLowerCase().trim();
        String nombreEn = TRADUCCION.getOrDefault(clave, clave);
        String unidadNorm = unidad != null ? unidad.toLowerCase() : "g";

        if (unidadNorm.equals("g") || unidadNorm.equals("ml")) {
            return cantidad + unidadNorm + " " + nombreEn;
        }
        if (unidadNorm.equals("diente")) {
            return cantidad + " clove " + nombreEn;
        }
        if (unidadNorm.equals("ud")) {
            return cantidad + " " + nombreEn;
        }
        return cantidad + " " + unidadNorm + " " + nombreEn;
    }
}
