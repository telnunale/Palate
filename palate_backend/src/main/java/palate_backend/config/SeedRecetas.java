package palate_backend.config;

import palate_backend.enums.DificultadReceta;
import palate_backend.enums.MetodoPreparacion;
import palate_backend.enums.RolIngrediente;
import palate_backend.model.Alimento;
import palate_backend.model.Receta;
import palate_backend.model.RecetaAlimento;
import palate_backend.repository.AlimentoRepository;
import palate_backend.repository.RecetaRepository;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * Carga inicial de recetas y alimentos. Solo se ejecuta cuando la tabla
 * de recetas esta vacia.
 */
@Configuration
public class SeedRecetas {

    private final Map<String, Alimento> cacheAlimentos = new HashMap<>();

    @Bean
    @Order(1)
    public CommandLineRunner inicializarRecetasPorDefecto(
            RecetaRepository recetaRepository,
            AlimentoRepository alimentoRepository) {

        return args -> {
            if (recetaRepository.count() > 0) {
                return;
            }

            crearRecetasBrocoli(recetaRepository, alimentoRepository);
            crearRecetasEspinacas(recetaRepository, alimentoRepository);
            crearRecetasPescado(recetaRepository, alimentoRepository);
            crearRecetasChampinones(recetaRepository, alimentoRepository);
            crearRecetasColiflor(recetaRepository, alimentoRepository);
            crearRecetasTomate(recetaRepository, alimentoRepository);
            crearRecetasCebolla(recetaRepository, alimentoRepository);
            crearRecetasHigado(recetaRepository, alimentoRepository);
        };
    }

    private void crearRecetasBrocoli(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Crema suave de brocoli y patata",
                "Crema cremosa donde el brocoli queda totalmente integrado.",
                "1. Pela y trocea la patata. 2. Lava el brocoli y separa los ramilletes. 3. Hierve ambos en caldo de verduras durante 15 minutos. 4. Tritura todo con la nata hasta obtener una crema fina. 5. Salpimienta y sirve caliente.",
                10, 20, DificultadReceta.FACIL,
                new Ing("Brocoli", "Verduras", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Patata", "Tuberculos", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Caldo de verduras", "Otros", "500", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Nata para cocinar", "Lacteos", "100", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Pasta al pesto con brocoli",
                "Pasta cremosa donde el pesto enmascara el sabor del brocoli.",
                "1. Cuece la pasta segun instrucciones. 2. En los ultimos 5 minutos anade los ramilletes de brocoli al agua. 3. Escurre. 4. Mezcla con pesto y queso parmesano rallado. 5. Sirve caliente.",
                5, 12, DificultadReceta.FACIL,
                new Ing("Brocoli", "Verduras", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Pasta", "Cereales", "250", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HERVIDO),
                new Ing("Pesto", "Condimentos", "80", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA),
                new Ing("Queso parmesano", "Lacteos", "40", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Brocoli al horno con ajo y limon",
                "Plato sencillo que respeta el sabor original del brocoli.",
                "1. Precalienta el horno a 200 grados. 2. Trocea el brocoli y dispon en bandeja. 3. Aliña con aceite, ajo picado, sal y zumo de limon. 4. Hornea 18 minutos hasta dorar. 5. Sirve recien hecho.",
                8, 18, DificultadReceta.FACIL,
                new Ing("Brocoli", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Ajo", "Condimentos", "3", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO),
                new Ing("Aceite de oliva", "Otros", "30", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Limon", "Frutas", "1", "ud", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Tortilla espanola con brocoli oculto",
                "El brocoli triturado pasa desapercibido entre la patata y el huevo.",
                "1. Tritura el brocoli previamente cocido. 2. Bate los huevos y mezcla con el brocoli. 3. Frie patata y cebolla en aceite hasta dorar. 4. Anade la mezcla de huevo y brocoli. 5. Cuaja por ambos lados y sirve.",
                10, 15, DificultadReceta.MEDIA,
                new Ing("Brocoli", "Verduras", "150", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.TRITURADO),
                new Ing("Huevo", "Proteinas", "5", "ud", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Patata", "Tuberculos", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO)
        );

        crear(rr, ar,
                "Salteado oriental de brocoli y pollo",
                "Salteado donde el brocoli mantiene textura crujiente.",
                "1. Corta el pollo en tiras y marina con salsa de soja 10 minutos. 2. Saltea el pollo en wok. 3. Anade los ramilletes de brocoli. 4. Anade jengibre rallado y soja. 5. Saltea 4 minutos mas y sirve con arroz.",
                12, 10, DificultadReceta.MEDIA,
                new Ing("Brocoli", "Verduras", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Pechuga de pollo", "Carnes", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.MARINADO),
                new Ing("Salsa de soja", "Condimentos", "40", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA),
                new Ing("Jengibre", "Condimentos", "10", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Arroz", "Cereales", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO)
        );
    }

    private void crearRecetasEspinacas(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Crema de espinacas con queso",
                "Crema suave que disimula la textura fibrosa de las espinacas.",
                "1. Saltea las espinacas con un poco de aceite. 2. Anade nata y queso crema. 3. Cocina 5 minutos a fuego suave. 4. Tritura hasta crema. 5. Sirve caliente con pan tostado.",
                8, 12, DificultadReceta.FACIL,
                new Ing("Espinacas", "Verduras", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Nata para cocinar", "Lacteos", "200", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Queso crema", "Lacteos", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Pan tostado", "Cereales", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO)
        );

        crear(rr, ar,
                "Lasana de espinacas y ricotta",
                "Las espinacas trituradas se integran en el relleno cremoso.",
                "1. Cuece las laminas de pasta. 2. Mezcla espinacas trituradas con ricotta y nuez moscada. 3. Monta capas alternando pasta, relleno y bechamel. 4. Cubre con queso. 5. Hornea 25 minutos a 180 grados.",
                20, 25, DificultadReceta.MEDIA,
                new Ing("Espinacas", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Ricotta", "Lacteos", "250", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.EN_SALSA),
                new Ing("Pasta para lasana", "Cereales", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Bechamel", "Lacteos", "300", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Queso mozzarella", "Lacteos", "150", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO)
        );

        crear(rr, ar,
                "Smoothie verde de espinacas y platano",
                "Bebida dulce donde el platano enmascara totalmente las espinacas.",
                "1. Pela el platano y trocealo. 2. Lava las espinacas. 3. Tritura todo con leche y miel hasta textura cremosa. 4. Sirve frio.",
                5, 0, DificultadReceta.FACIL,
                new Ing("Espinacas", "Verduras", "80", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.TRITURADO),
                new Ing("Platano", "Frutas", "2", "ud", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Leche", "Lacteos", "250", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.CRUDO),
                new Ing("Miel", "Otros", "15", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Tortilla francesa de espinacas",
                "Tortilla rapida donde las espinacas quedan envueltas en huevo.",
                "1. Saltea las espinacas en sarten. 2. Bate los huevos y salpimienta. 3. Anade las espinacas a los huevos. 4. Cuaja en sarten antiadherente con poco aceite. 5. Pliega y sirve.",
                5, 8, DificultadReceta.FACIL,
                new Ing("Espinacas", "Verduras", "150", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Huevo", "Proteinas", "3", "ud", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Aceite de oliva", "Otros", "15", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Garbanzos guisados con espinacas",
                "Guiso tradicional donde las espinacas se mezclan con sabores intensos.",
                "1. Pocha la cebolla en aceite. 2. Anade pimenton y comino. 3. Anade los garbanzos cocidos y caldo. 4. Incorpora las espinacas y deja cocinar 10 minutos. 5. Sirve caliente.",
                10, 15, DificultadReceta.FACIL,
                new Ing("Espinacas", "Verduras", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Garbanzos cocidos", "Legumbres", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.EN_SALSA),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Pimenton", "Condimentos", "5", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA),
                new Ing("Caldo de verduras", "Otros", "300", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HERVIDO)
        );
    }

    private void crearRecetasPescado(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Hamburguesas de pescado y patata",
                "El pescado triturado se mezcla con patata y pierde olor caracteristico.",
                "1. Hierve la patata y machaca. 2. Tritura el pescado cocido. 3. Mezcla con huevo, perejil y pan rallado. 4. Forma hamburguesas. 5. Frie en sarten 3 minutos por lado.",
                15, 12, DificultadReceta.FACIL,
                new Ing("Merluza", "Pescados", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Patata", "Tuberculos", "300", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Huevo", "Proteinas", "1", "ud", RolIngrediente.SECUNDARIO, MetodoPreparacion.CRUDO),
                new Ing("Pan rallado", "Cereales", "60", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Perejil", "Condimentos", "5", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Salmon al horno con miel y mostaza",
                "Marinada dulce-salada que reduce el olor caracteristico del salmon.",
                "1. Precalienta el horno a 200 grados. 2. Mezcla miel, mostaza y soja para la marinada. 3. Pinta el salmon. 4. Hornea 12 minutos. 5. Sirve con verduras al vapor.",
                8, 12, DificultadReceta.FACIL,
                new Ing("Salmon", "Pescados", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Miel", "Otros", "30", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.MARINADO),
                new Ing("Mostaza", "Condimentos", "20", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.MARINADO),
                new Ing("Salsa de soja", "Condimentos", "20", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.MARINADO)
        );

        crear(rr, ar,
                "Croquetas de bacalao",
                "El bacalao queda envuelto en bechamel y rebozado, suaviza textura.",
                "1. Desmiga el bacalao desalado. 2. Prepara bechamel espesa. 3. Mezcla bacalao con bechamel y deja enfriar. 4. Forma croquetas y empana en huevo y pan rallado. 5. Frie en aceite caliente hasta dorar.",
                25, 10, DificultadReceta.MEDIA,
                new Ing("Bacalao desalado", "Pescados", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Bechamel", "Lacteos", "400", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Pan rallado", "Cereales", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Huevo", "Proteinas", "2", "ud", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Atun con tomate y cebolla",
                "El sofrito de tomate disimula el sabor pronunciado del atun.",
                "1. Pocha cebolla en aceite. 2. Anade tomate triturado y deja reducir 15 minutos. 3. Incorpora atun en lata escurrido. 4. Cocina 5 minutos mas. 5. Sirve sobre arroz blanco o con pan.",
                10, 20, DificultadReceta.FACIL,
                new Ing("Atun en lata", "Pescados", "200", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.EN_SALSA),
                new Ing("Tomate triturado", "Verduras", "400", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Cebolla", "Verduras", "150", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Aceite de oliva", "Otros", "30", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Merluza a la plancha con limon",
                "Plato clasico para quien tolera el pescado en su forma natural.",
                "1. Salpimienta los lomos de merluza. 2. Calienta plancha con poco aceite. 3. Cocina 3 minutos por lado. 4. Riega con zumo de limon y perejil. 5. Sirve con patatas cocidas.",
                5, 8, DificultadReceta.FACIL,
                new Ing("Merluza", "Pescados", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Limon", "Frutas", "1", "ud", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Perejil", "Condimentos", "5", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Patata", "Tuberculos", "400", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO)
        );
    }

    private void crearRecetasChampinones(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Crema de champinones",
                "La textura grumosa desaparece al triturar.",
                "1. Limpia y trocea los champinones. 2. Saltea con cebolla y ajo. 3. Anade caldo y nata. 4. Cocina 10 minutos. 5. Tritura todo y sirve.",
                10, 15, DificultadReceta.FACIL,
                new Ing("Champinones", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Ajo", "Condimentos", "2", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Caldo de pollo", "Otros", "400", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Nata para cocinar", "Lacteos", "150", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA)
        );

        crear(rr, ar,
                "Risotto de champinones",
                "Plato cremoso donde el arroz absorbe los sabores.",
                "1. Saltea cebolla con mantequilla. 2. Anade arroz arborio y vino blanco. 3. Incorpora caldo poco a poco removiendo. 4. Anade champinones laminados a mitad de coccion. 5. Termina con queso parmesano y mantequilla.",
                10, 25, DificultadReceta.MEDIA,
                new Ing("Champinones", "Verduras", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.EN_SALSA),
                new Ing("Arroz arborio", "Cereales", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HERVIDO),
                new Ing("Cebolla", "Verduras", "80", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Caldo de verduras", "Otros", "1", "l", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Queso parmesano", "Lacteos", "60", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Vino blanco", "Otros", "100", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA)
        );

        crear(rr, ar,
                "Champinones al ajillo",
                "Tapa clasica espanola que potencia el sabor del champinon.",
                "1. Limpia y lamina los champinones. 2. Calienta aceite con ajo y guindilla. 3. Anade los champinones. 4. Saltea 8 minutos a fuego fuerte. 5. Termina con perejil y un chorro de vino blanco.",
                8, 10, DificultadReceta.FACIL,
                new Ing("Champinones", "Verduras", "500", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Ajo", "Condimentos", "4", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Aceite de oliva", "Otros", "40", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Perejil", "Condimentos", "5", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Vino blanco", "Otros", "50", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA)
        );

        crear(rr, ar,
                "Pollo al curry con champinones",
                "El curry y la leche de coco enmascaran el sabor terroso.",
                "1. Trocea el pollo y dorelo. 2. Anade champinones laminados. 3. Incorpora cebolla y curry en polvo. 4. Anade leche de coco y cocina 15 minutos. 5. Sirve con arroz basmati.",
                12, 20, DificultadReceta.MEDIA,
                new Ing("Champinones", "Verduras", "300", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Pechuga de pollo", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Leche de coco", "Otros", "400", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Curry en polvo", "Condimentos", "10", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Arroz basmati", "Cereales", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO)
        );

        crear(rr, ar,
                "Hamburguesa con champinones salteados",
                "Los champinones salteados acompanan sin dominar el plato.",
                "1. Forma hamburguesas con la carne y salpimienta. 2. Saltea champinones laminados con cebolla. 3. Cocina las hamburguesas a la plancha. 4. Monta el bocadillo con queso y los champinones. 5. Sirve caliente.",
                10, 12, DificultadReceta.MEDIA,
                new Ing("Champinones", "Verduras", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Carne picada", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Pan de hamburguesa", "Cereales", "4", "ud", RolIngrediente.SECUNDARIO, MetodoPreparacion.HORNEADO),
                new Ing("Queso cheddar", "Lacteos", "80", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO)
        );
    }

    private void crearRecetasColiflor(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Pure de coliflor",
                "Alternativa al pure de patata, el coliflor desaparece visualmente.",
                "1. Cuece los ramilletes de coliflor en leche 12 minutos. 2. Escurre y reserva un poco de leche. 3. Tritura con mantequilla, sal y nuez moscada. 4. Ajusta textura con la leche reservada. 5. Sirve como guarnicion.",
                5, 15, DificultadReceta.FACIL,
                new Ing("Coliflor", "Verduras", "500", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Leche", "Lacteos", "300", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Mantequilla", "Lacteos", "30", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Nuez moscada", "Condimentos", "2", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Coliflor gratinada con bechamel",
                "La bechamel y el queso suavizan el sabor caracteristico.",
                "1. Cuece la coliflor 10 minutos. 2. Prepara bechamel ligera. 3. Coloca la coliflor en fuente y cubre con bechamel. 4. Espolvorea queso rallado. 5. Gratina en horno 10 minutos.",
                10, 20, DificultadReceta.MEDIA,
                new Ing("Coliflor", "Verduras", "600", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Bechamel", "Lacteos", "400", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Queso rallado", "Lacteos", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO)
        );

        crear(rr, ar,
                "Arroz de coliflor salteado",
                "La coliflor adopta apariencia de arroz, se camufla totalmente.",
                "1. Tritura la coliflor cruda hasta obtener grano tipo arroz. 2. Saltea con ajo y aceite. 3. Anade verduras picadas y huevo. 4. Sazona con soja. 5. Sirve caliente.",
                10, 8, DificultadReceta.FACIL,
                new Ing("Coliflor", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Huevo", "Proteinas", "2", "ud", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Salsa de soja", "Condimentos", "30", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA),
                new Ing("Ajo", "Condimentos", "2", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Zanahoria", "Verduras", "80", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO)
        );

        crear(rr, ar,
                "Coliflor al curry con garbanzos",
                "Plato indio donde las especias dominan sobre el sabor de la coliflor.",
                "1. Saltea cebolla con curry y comino. 2. Anade tomate triturado y cocina 5 minutos. 3. Incorpora coliflor y garbanzos. 4. Anade leche de coco y cuece 15 minutos. 5. Sirve con arroz basmati.",
                10, 20, DificultadReceta.FACIL,
                new Ing("Coliflor", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.EN_SALSA),
                new Ing("Garbanzos cocidos", "Legumbres", "300", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Curry en polvo", "Condimentos", "10", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA),
                new Ing("Leche de coco", "Otros", "400", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Tomate triturado", "Verduras", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO)
        );

        crear(rr, ar,
                "Coliflor crujiente al horno",
                "El horneado intenso aporta textura crujiente y caramelizada.",
                "1. Precalienta el horno a 220 grados. 2. Trocea la coliflor y aliña con aceite, paprika, ajo en polvo y sal. 3. Hornea 25 minutos hasta dorar bien. 4. Da la vuelta a mitad de coccion. 5. Sirve recien hecha.",
                8, 25, DificultadReceta.FACIL,
                new Ing("Coliflor", "Verduras", "500", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Paprika", "Condimentos", "5", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO),
                new Ing("Ajo en polvo", "Condimentos", "3", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO),
                new Ing("Aceite de oliva", "Otros", "30", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );
    }

    private void crearRecetasTomate(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Salsa marinara para pasta",
                "Salsa cocinada y triturada, sin trozos visibles de tomate.",
                "1. Pocha cebolla y ajo en aceite. 2. Anade tomate triturado y oregano. 3. Cocina a fuego lento 30 minutos. 4. Tritura para textura fina. 5. Sirve con pasta.",
                5, 30, DificultadReceta.FACIL,
                new Ing("Tomate triturado", "Verduras", "500", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.EN_SALSA),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Ajo", "Condimentos", "3", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Oregano", "Condimentos", "3", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA),
                new Ing("Pasta", "Cereales", "300", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO)
        );

        crear(rr, ar,
                "Pizza margherita casera",
                "Tomate cocido en salsa, no aparece crudo en ningun momento.",
                "1. Estira la masa. 2. Extiende salsa de tomate cocida. 3. Anade mozzarella en trozos. 4. Hornea 12 minutos a 230 grados. 5. Termina con albahaca fresca.",
                15, 12, DificultadReceta.MEDIA,
                new Ing("Masa de pizza", "Cereales", "300", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Tomate triturado", "Verduras", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Mozzarella", "Lacteos", "200", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Albahaca", "Condimentos", "5", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Tomates rellenos al horno",
                "Tomates horneados con relleno sabroso, textura mas suave.",
                "1. Vacia los tomates. 2. Mezcla atun, cebolla y huevo cocido. 3. Rellena los tomates. 4. Hornea 20 minutos a 180 grados. 5. Sirve templado.",
                15, 20, DificultadReceta.MEDIA,
                new Ing("Tomate", "Verduras", "4", "ud", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Atun en lata", "Pescados", "150", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.CRUDO),
                new Ing("Cebolla", "Verduras", "80", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Huevo", "Proteinas", "2", "ud", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HERVIDO)
        );

        crear(rr, ar,
                "Gazpacho andaluz suave",
                "Sopa fria triturada, el tomate desaparece como pieza.",
                "1. Tritura tomate, pepino, pimiento, ajo y pan remojado. 2. Anade aceite, vinagre y sal. 3. Pasa por colador para textura sedosa. 4. Enfria minimo 2 horas. 5. Sirve muy frio.",
                15, 0, DificultadReceta.FACIL,
                new Ing("Tomate", "Verduras", "1", "kg", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Pepino", "Verduras", "200", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.TRITURADO),
                new Ing("Pimiento verde", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.TRITURADO),
                new Ing("Ajo", "Condimentos", "1", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.TRITURADO),
                new Ing("Aceite de oliva", "Otros", "60", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Vinagre de jerez", "Condimentos", "20", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Ensalada caprese clasica",
                "Plato italiano que muestra el tomate crudo en su forma original.",
                "1. Lamina los tomates. 2. Lamina la mozzarella del mismo grosor. 3. Alterna en plato con hojas de albahaca. 4. Aliña con aceite, sal y pimienta. 5. Sirve a temperatura ambiente.",
                10, 0, DificultadReceta.FACIL,
                new Ing("Tomate", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.CRUDO),
                new Ing("Mozzarella", "Lacteos", "250", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.CRUDO),
                new Ing("Albahaca", "Condimentos", "10", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Aceite de oliva", "Otros", "30", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );
    }

    private void crearRecetasCebolla(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Sopa de cebolla francesa",
                "La coccion larga elimina el picor caracteristico.",
                "1. Pocha la cebolla en mantequilla 30 minutos hasta caramelizar. 2. Anade caldo de carne y vino. 3. Cuece 15 minutos. 4. Sirve en cazuela con pan tostado y queso. 5. Gratina hasta dorar.",
                10, 45, DificultadReceta.MEDIA,
                new Ing("Cebolla", "Verduras", "600", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Caldo de carne", "Otros", "800", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO),
                new Ing("Mantequilla", "Lacteos", "40", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Pan tostado", "Cereales", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO),
                new Ing("Queso gruyere", "Lacteos", "120", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO),
                new Ing("Vino blanco", "Otros", "100", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA)
        );

        crear(rr, ar,
                "Quiche de cebolla caramelizada",
                "La cebolla caramelizada queda dulce y se mezcla con el huevo.",
                "1. Cocina la cebolla a fuego lento 25 minutos hasta caramelizar. 2. Bate huevos con nata y queso. 3. Pon la cebolla sobre la masa quebrada. 4. Vierte la mezcla de huevo. 5. Hornea 35 minutos a 180 grados.",
                15, 35, DificultadReceta.MEDIA,
                new Ing("Cebolla", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.HORNEADO),
                new Ing("Masa quebrada", "Cereales", "1", "ud", RolIngrediente.SECUNDARIO, MetodoPreparacion.HORNEADO),
                new Ing("Huevo", "Proteinas", "3", "ud", RolIngrediente.SECUNDARIO, MetodoPreparacion.HORNEADO),
                new Ing("Nata para cocinar", "Lacteos", "200", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.HORNEADO),
                new Ing("Queso emmental", "Lacteos", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO)
        );

        crear(rr, ar,
                "Hummus suave de garbanzos",
                "Receta sin cebolla cruda, usa cebolla en polvo en cantidad minima.",
                "1. Tritura garbanzos cocidos. 2. Anade tahini, ajo en polvo y zumo de limon. 3. Anade muy poca cebolla en polvo. 4. Aniade aceite hasta cremosidad. 5. Sirve frio con pan pita.",
                8, 0, DificultadReceta.FACIL,
                new Ing("Garbanzos cocidos", "Legumbres", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Tahini", "Condimentos", "60", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.CRUDO),
                new Ing("Cebolla en polvo", "Condimentos", "2", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Limon", "Frutas", "1", "ud", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Aceite de oliva", "Otros", "40", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Hamburguesa con cebolla pochada",
                "Cebolla cocinada largo rato, dulce y sin picor.",
                "1. Cocina la cebolla cortada en juliana a fuego muy lento 20 minutos. 2. Forma hamburguesas y cocina a la plancha. 3. Tuesta el pan. 4. Monta con la cebolla pochada y queso. 5. Sirve caliente.",
                10, 25, DificultadReceta.MEDIA,
                new Ing("Cebolla", "Verduras", "300", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Carne picada", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Pan de hamburguesa", "Cereales", "4", "ud", RolIngrediente.SECUNDARIO, MetodoPreparacion.HORNEADO),
                new Ing("Queso cheddar", "Lacteos", "80", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.HORNEADO)
        );

        crear(rr, ar,
                "Aros de cebolla rebozados",
                "Rebozado crujiente que oculta la textura interior.",
                "1. Corta la cebolla en aros gruesos. 2. Reboza en harina, huevo y pan rallado. 3. Frie en abundante aceite caliente. 4. Escurre sobre papel. 5. Sirve con salsa barbacoa.",
                10, 8, DificultadReceta.MEDIA,
                new Ing("Cebolla", "Verduras", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Harina", "Cereales", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Pan rallado", "Cereales", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Huevo", "Proteinas", "2", "ud", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Salsa barbacoa", "Condimentos", "60", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );
    }

    private void crearRecetasHigado(RecetaRepository rr, AlimentoRepository ar) {
        crear(rr, ar,
                "Pate casero de higado",
                "Triturado total, el higado pierde toda su textura caracteristica.",
                "1. Saltea higado de pollo con cebolla y ajo. 2. Anade brandy y deja evaporar. 3. Tritura todo con mantequilla y especias. 4. Pon en molde y enfria 4 horas. 5. Sirve con tostadas.",
                15, 12, DificultadReceta.MEDIA,
                new Ing("Higado de pollo", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.TRITURADO),
                new Ing("Mantequilla", "Lacteos", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.TRITURADO),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Ajo", "Condimentos", "2", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Brandy", "Otros", "30", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.EN_SALSA)
        );

        crear(rr, ar,
                "Albondigas con higado oculto",
                "El higado queda completamente integrado entre carne y especias.",
                "1. Tritura el higado. 2. Mezcla con carne picada, pan remojado, huevo y especias. 3. Forma albondigas. 4. Frie y cubre con salsa de tomate. 5. Cocina 15 minutos en la salsa.",
                15, 20, DificultadReceta.MEDIA,
                new Ing("Higado de ternera", "Carnes", "150", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.TRITURADO),
                new Ing("Carne picada", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Tomate triturado", "Verduras", "400", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Pan rallado", "Cereales", "60", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO),
                new Ing("Huevo", "Proteinas", "1", "ud", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Higado encebollado tradicional",
                "Plato clasico para quien tolera el higado en su forma natural.",
                "1. Pocha 3 cebollas en juliana muy lentamente. 2. Salpimienta el higado y enharinalo. 3. Frie a fuego fuerte 1 minuto por lado. 4. Cubre con la cebolla pochada. 5. Sirve con pan.",
                10, 30, DificultadReceta.MEDIA,
                new Ing("Higado de ternera", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.FRITO),
                new Ing("Cebolla", "Verduras", "500", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Harina", "Cereales", "30", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Aceite de oliva", "Otros", "40", "ml", RolIngrediente.COMPLEMENTO, MetodoPreparacion.CRUDO)
        );

        crear(rr, ar,
                "Higado al jerez",
                "El jerez aporta dulzor que suaviza el sabor metalico.",
                "1. Sazona el higado y pasalo por harina. 2. Marca en sarten con aceite. 3. Anade ajo picado y jerez. 4. Reduce 5 minutos. 5. Sirve con perejil y patatas.",
                8, 15, DificultadReceta.MEDIA,
                new Ing("Higado de ternera", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.MARINADO),
                new Ing("Vino de jerez", "Otros", "100", "ml", RolIngrediente.SECUNDARIO, MetodoPreparacion.MARINADO),
                new Ing("Ajo", "Condimentos", "3", "diente", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Harina", "Cereales", "30", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Patata", "Tuberculos", "300", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO)
        );

        crear(rr, ar,
                "Bolonesa enriquecida con higado",
                "El higado triturado aporta hierro sin notarse en la salsa.",
                "1. Tritura un poco de higado finamente. 2. Sofrie cebolla, zanahoria y apio. 3. Anade carne picada y el higado. 4. Incorpora tomate y vino. 5. Cocina a fuego lento 40 minutos y sirve con pasta.",
                15, 45, DificultadReceta.MEDIA,
                new Ing("Higado de pollo", "Carnes", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.TRITURADO),
                new Ing("Carne picada", "Carnes", "400", "g", RolIngrediente.PROTAGONISTA, MetodoPreparacion.EN_SALSA),
                new Ing("Tomate triturado", "Verduras", "500", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.EN_SALSA),
                new Ing("Cebolla", "Verduras", "100", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.FRITO),
                new Ing("Zanahoria", "Verduras", "100", "g", RolIngrediente.COMPLEMENTO, MetodoPreparacion.FRITO),
                new Ing("Pasta", "Cereales", "300", "g", RolIngrediente.SECUNDARIO, MetodoPreparacion.HERVIDO)
        );
    }


    /**
     * Construye y persiste una receta junto con todos sus ingredientes
     * en una unica transaccion. Centraliza el patron de creacion para
     * que cada receta del seed se exprese como una llamada compacta y
     * legible, sin repetir la logica de instanciacion ni la resolucion
     * de alimentos contra la base de datos.
     */
    @Transactional
    protected void crear(RecetaRepository rr, AlimentoRepository ar,
                         String titulo, String descripcion, String instrucciones,
                         int tiempoPreparacion, int tiempoCoccion, DificultadReceta dificultad,
                         Ing... ingredientes) {

        Receta receta = new Receta(titulo, instrucciones, tiempoPreparacion, tiempoCoccion, dificultad);
        receta.setDescripcion(descripcion);
        receta.setGeneradaPorIa(false);
        rr.save(receta);

        for (Ing ing : ingredientes) {
            Alimento alimento = obtenerOCrearAlimento(ar, ing.nombre, ing.categoria);

            RecetaAlimento ra = new RecetaAlimento();
            ra.setReceta(receta);
            ra.setAlimento(alimento);
            ra.setCantidad(new BigDecimal(ing.cantidad));
            ra.setUnidadMedida(ing.unidad);
            ra.setRol(ing.rol);
            ra.setMetodoPreparacion(ing.metodo);
            ra.setOculto(false);
            ra.setCantidadMinima(new BigDecimal(ing.cantidad).multiply(new BigDecimal("0.3")));
            ra.setDescripcionNutricional(construirDescripcionEdamam(ing));

            receta.getIngredientes().add(ra);
        }

        rr.save(receta);
    }

    private static final Map<String, String> TRADUCCION_INGREDIENTES = Map.ofEntries(
            Map.entry("Aceite de oliva", "olive oil"),
            Map.entry("Ajo en polvo", "garlic powder"),
            Map.entry("Ajo", "garlic"),
            Map.entry("Albahaca", "basil"),
            Map.entry("Arroz arborio", "arborio rice"),
            Map.entry("Arroz basmati", "basmati rice"),
            Map.entry("Arroz", "rice"),
            Map.entry("Atun en lata", "canned tuna"),
            Map.entry("Bacalao desalado", "cod"),
            Map.entry("Bechamel", "bechamel sauce"),
            Map.entry("Brandy", "brandy"),
            Map.entry("Brocoli", "broccoli"),
            Map.entry("Caldo de carne", "beef broth"),
            Map.entry("Caldo de pollo", "chicken broth"),
            Map.entry("Caldo de verduras", "vegetable broth"),
            Map.entry("Carne picada", "ground beef"),
            Map.entry("Cebolla en polvo", "onion powder"),
            Map.entry("Cebolla", "onion"),
            Map.entry("Champinones", "mushrooms"),
            Map.entry("Coliflor", "cauliflower"),
            Map.entry("Curry en polvo", "curry powder"),
            Map.entry("Espinacas", "spinach"),
            Map.entry("Garbanzos cocidos", "cooked chickpeas"),
            Map.entry("Harina", "flour"),
            Map.entry("Higado de pollo", "chicken liver"),
            Map.entry("Higado de ternera", "beef liver"),
            Map.entry("Huevo", "egg"),
            Map.entry("Jengibre", "ginger"),
            Map.entry("Leche de coco", "coconut milk"),
            Map.entry("Leche", "milk"),
            Map.entry("Limon", "lemon"),
            Map.entry("Mantequilla", "butter"),
            Map.entry("Masa de pizza", "pizza dough"),
            Map.entry("Masa quebrada", "shortcrust pastry"),
            Map.entry("Merluza", "hake"),
            Map.entry("Miel", "honey"),
            Map.entry("Mostaza", "mustard"),
            Map.entry("Mozzarella", "mozzarella cheese"),
            Map.entry("Nata para cocinar", "cooking cream"),
            Map.entry("Nuez moscada", "nutmeg"),
            Map.entry("Oregano", "oregano"),
            Map.entry("Pan de hamburguesa", "burger bun"),
            Map.entry("Pan rallado", "breadcrumbs"),
            Map.entry("Pan tostado", "toasted bread"),
            Map.entry("Paprika", "paprika"),
            Map.entry("Pasta para lasana", "lasagna sheets"),
            Map.entry("Pasta", "pasta"),
            Map.entry("Patata", "potato"),
            Map.entry("Pechuga de pollo", "chicken breast"),
            Map.entry("Pepino", "cucumber"),
            Map.entry("Perejil", "parsley"),
            Map.entry("Pesto", "pesto sauce"),
            Map.entry("Pimenton", "paprika"),
            Map.entry("Pimiento verde", "green bell pepper"),
            Map.entry("Platano", "banana"),
            Map.entry("Queso cheddar", "cheddar cheese"),
            Map.entry("Queso crema", "cream cheese"),
            Map.entry("Queso emmental", "emmental cheese"),
            Map.entry("Queso gruyere", "gruyere cheese"),
            Map.entry("Queso mozzarella", "mozzarella cheese"),
            Map.entry("Queso parmesano", "parmesan cheese"),
            Map.entry("Queso rallado", "grated cheese"),
            Map.entry("Ricotta", "ricotta cheese"),
            Map.entry("Salmon", "salmon"),
            Map.entry("Salsa barbacoa", "barbecue sauce"),
            Map.entry("Salsa de soja", "soy sauce"),
            Map.entry("Tahini", "tahini"),
            Map.entry("Tomate triturado", "crushed tomato"),
            Map.entry("Tomate", "tomato"),
            Map.entry("Vinagre de jerez", "sherry vinegar"),
            Map.entry("Vino blanco", "white wine"),
            Map.entry("Vino de jerez", "sherry wine"),
            Map.entry("Zanahoria", "carrot")
    );

    private String construirDescripcionEdamam(Ing ing) {
        String nombreEn = TRADUCCION_INGREDIENTES.getOrDefault(ing.nombre, ing.nombre.toLowerCase());
        String unidadNorm = ing.unidad.toLowerCase();

        if (unidadNorm.equals("g") || unidadNorm.equals("ml")) {
            return ing.cantidad + unidadNorm + " " + nombreEn;
        }
        if (unidadNorm.equals("diente")) {
            return ing.cantidad + " clove " + nombreEn;
        }
        if (unidadNorm.equals("ud")) {
            return ing.cantidad + " " + nombreEn;
        }
        return ing.cantidad + " " + unidadNorm + " " + nombreEn;
    }

    /**
     * Resuelve un alimento contra la BD evitando duplicados. Usa el
     * repositorio para tolerar mayusculas/minusculas y mantiene una
     * cache local para no consultar dos veces el mismo alimento dentro
     * de una misma ejecucion del seed.
     */
    private Alimento obtenerOCrearAlimento(AlimentoRepository ar, String nombre, String categoria) {
        Alimento cacheado = cacheAlimentos.get(nombre.toLowerCase());
        if (cacheado != null) return cacheado;

        Alimento alimento = ar.findByNombreIgnoreCase(nombre)
                .orElseGet(() -> ar.save(new Alimento(nombre, categoria)));

        cacheAlimentos.put(nombre.toLowerCase(), alimento);
        return alimento;
    }

    /**
     * Estructura interna para describir un ingrediente sin saturar la
     * firma del metodo {@link #crear}. No se persiste en BD, solo
     * agrupa los datos hasta que se construye la entidad
     * {@link RecetaAlimento}.
     */
    private static final class Ing {
        final String nombre;
        final String categoria;
        final String cantidad;
        final String unidad;
        final RolIngrediente rol;
        final MetodoPreparacion metodo;

        Ing(String nombre, String categoria, String cantidad, String unidad,
            RolIngrediente rol, MetodoPreparacion metodo) {
            this.nombre = nombre;
            this.categoria = categoria;
            this.cantidad = cantidad;
            this.unidad = unidad;
            this.rol = rol;
            this.metodo = metodo;
        }
    }
}
