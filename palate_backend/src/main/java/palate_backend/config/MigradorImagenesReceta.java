package palate_backend.config;

import palate_backend.model.Receta;
import palate_backend.repository.RecetaRepository;
import palate_backend.service.ClasificadorImagen;
import palate_backend.service.FluxImagenService;
import palate_backend.service.PexelsImagenService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * Migra al arrancar recetas cuya imagen no este servida por Cloudinary
 * aplicando la cascada FLUX -> Pexels -> pool tematico.
 */
@Configuration
public class MigradorImagenesReceta {

    @Bean
    @Order(2)
    public CommandLineRunner asignarImagenesARecetasSinFoto(MigradorTask migradorTask) {
        return args -> migradorTask.migrar();
    }

    @Component
    public static class MigradorTask {

        private final RecetaRepository recetaRepository;
        private final ClasificadorImagen clasificadorImagen;
        private final PexelsImagenService pexelsImagenService;
        private final FluxImagenService fluxImagenService;

        public MigradorTask(RecetaRepository recetaRepository,
                            ClasificadorImagen clasificadorImagen,
                            PexelsImagenService pexelsImagenService,
                            FluxImagenService fluxImagenService) {
            this.recetaRepository = recetaRepository;
            this.clasificadorImagen = clasificadorImagen;
            this.pexelsImagenService = pexelsImagenService;
            this.fluxImagenService = fluxImagenService;
        }

        @Transactional
        public void migrar() {
            List<Receta> recetas = recetaRepository.findAll();
            int actualizadas = 0;
            for (Receta r : recetas) {
                if (yaTieneImagenPermanente(r.getImagenUrl())) continue;

                Optional<String> flux = fluxImagenService.generarYGuardar(
                        r.getId(), r.getTitulo());
                String nueva;
                if (flux.isPresent()) {
                    nueva = flux.get();
                } else {
                    Optional<String> pexels = pexelsImagenService.buscarImagen(r.getTitulo());
                    nueva = pexels.orElseGet(() -> clasificadorImagen.elegirImagen(r));
                }

                if (!nueva.equals(r.getImagenUrl())) {
                    r.setImagenUrl(nueva);
                    recetaRepository.save(r);
                    actualizadas++;
                }
            }
            if (actualizadas > 0) {
                System.out.println("[MigradorImagenesReceta] Imagenes reasignadas a "
                        + actualizadas + " recetas.");
            }
        }

        private boolean yaTieneImagenPermanente(String url) {
            if (url == null || url.isBlank()) return false;
            return url.contains("res.cloudinary.com")
                    || url.contains("images.pexels.com")
                    || url.contains("images.unsplash.com");
        }
    }
}
