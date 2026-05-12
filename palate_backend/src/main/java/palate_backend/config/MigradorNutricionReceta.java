package palate_backend.config;

import palate_backend.model.Receta;
import palate_backend.repository.RecetaRepository;
import palate_backend.service.RecetaGeneradorService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Calcula calorias y macros via Gemini para recetas que no las tengan.
 * Idempotente: solo procesa filas con calorias_total NULL.
 */
@Configuration
public class MigradorNutricionReceta {

    @Bean
    @Order(3)
    public CommandLineRunner asignarNutricionAlimentos(MigradorNutricionTask task) {
        return args -> task.migrar();
    }

    @Component
    public static class MigradorNutricionTask {

        private final RecetaRepository recetaRepository;
        private final RecetaGeneradorService recetaGeneradorService;

        public MigradorNutricionTask(RecetaRepository recetaRepository,
                                     RecetaGeneradorService recetaGeneradorService) {
            this.recetaRepository = recetaRepository;
            this.recetaGeneradorService = recetaGeneradorService;
        }

        @Transactional
        public void migrar() {
            List<Receta> recetas = recetaRepository.findAll();
            int actualizadas = 0;
            for (Receta r : recetas) {
                if (r.getCaloriasTotal() != null) continue;
                recetaGeneradorService.calcularYAplicarNutricion(r);
                if (r.getCaloriasTotal() != null) {
                    recetaRepository.save(r);
                    actualizadas++;
                }
            }
            if (actualizadas > 0) {
                System.out.println("[MigradorNutricionReceta] Nutricion calculada en "
                        + actualizadas + " recetas via Gemini.");
            }
        }
    }
}
