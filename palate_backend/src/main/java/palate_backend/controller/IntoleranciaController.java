package palate_backend.controller;

import palate_backend.dto.IntoleranciaDTO;
import palate_backend.service.IntoleranciaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/intolerancias")
public class IntoleranciaController {

    private final IntoleranciaService intoleranciaService;

    @Autowired
    public IntoleranciaController(IntoleranciaService intoleranciaService) {
        this.intoleranciaService = intoleranciaService;
    }

    @GetMapping("/{usuarioId}")
    public ResponseEntity<Object> obtenerPorUsuario(@PathVariable Long usuarioId) {
        List<IntoleranciaDTO> intolerancias = intoleranciaService.obtenerPorUsuario(usuarioId);
        return ResponseEntity.ok(intolerancias);
    }

    @PostMapping
    public ResponseEntity<Object> crear(@RequestBody Map<String, Object> datos) {
        Long usuarioId = Long.valueOf(datos.get("usuarioId").toString());
        Long alimentoId = Long.valueOf(datos.get("alimentoId").toString());
        int nivelRechazo = Integer.parseInt(datos.get("nivelRechazo").toString());

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> motivos = (List<Map<String, Object>>) datos.get("motivos");

        try {
            intoleranciaService.crear(usuarioId, alimentoId, nivelRechazo, motivos);
            Map<String, String> respuesta = new HashMap<>();
            respuesta.put("mensaje", "Intolerancia registrada correctamente");
            return ResponseEntity.ok(respuesta);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Object> eliminar(@PathVariable Long id) {
        intoleranciaService.eliminar(id);
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("mensaje", "Intolerancia eliminada correctamente");
        return ResponseEntity.ok(respuesta);
    }
}
