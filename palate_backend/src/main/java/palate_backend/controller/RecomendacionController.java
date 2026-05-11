package palate_backend.controller;

import palate_backend.dto.RecetaRecomendadaDTO;
import palate_backend.service.RecomendacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recomendaciones")
public class RecomendacionController {

    private final RecomendacionService recomendacionService;

    @Autowired
    public RecomendacionController(RecomendacionService recomendacionService) {
        this.recomendacionService = recomendacionService;
    }

    @GetMapping("/{usuarioId}")
    public ResponseEntity<List<RecetaRecomendadaDTO>> obtenerRecomendaciones(
            @PathVariable Long usuarioId) {
        List<RecetaRecomendadaDTO> recomendaciones =
                recomendacionService.obtenerRecomendaciones(usuarioId);
        return ResponseEntity.ok(recomendaciones);
    }
}
