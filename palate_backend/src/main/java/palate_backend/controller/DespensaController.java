package palate_backend.controller;

import palate_backend.dto.ProductoDespensaDTO;
import palate_backend.service.DespensaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/despensa")
public class DespensaController {

    private final DespensaService despensaService;

    @Autowired
    public DespensaController(DespensaService despensaService) {
        this.despensaService = despensaService;
    }

    @GetMapping("/{usuarioId}")
    public ResponseEntity<Object> obtenerPorUsuario(@PathVariable Long usuarioId) {
        List<ProductoDespensaDTO> productos = despensaService.obtenerPorUsuario(usuarioId);
        return ResponseEntity.ok(productos);
    }

    @PostMapping
    public ResponseEntity<Object> añadir(@RequestBody Map<String, Object> datos) {
        Long usuarioId = Long.valueOf(datos.get("usuarioId").toString());
        Long alimentoId = Long.valueOf(datos.get("alimentoId").toString());
        LocalDate fechaCaducidad = LocalDate.parse(datos.get("fechaCaducidad").toString());
        BigDecimal cantidad = new BigDecimal(datos.get("cantidad").toString());
        String unidad = (String) datos.get("unidad");

        try {
            ProductoDespensaDTO producto = despensaService.añadir(usuarioId, alimentoId, fechaCaducidad, cantidad, unidad);
            return ResponseEntity.ok(producto);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Object> actualizar(@PathVariable Long id, @RequestBody Map<String, Object> datos) {
        try {
            ProductoDespensaDTO producto = despensaService.actualizar(id, datos);
            return ResponseEntity.ok(producto);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Object> eliminar(@PathVariable Long id) {
        despensaService.eliminar(id);
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("mensaje", "Producto eliminado correctamente");
        return ResponseEntity.ok(respuesta);
    }

    @GetMapping("/{usuarioId}/proximos/{dias}")
    public ResponseEntity<Object> obtenerProximosACaducar(@PathVariable Long usuarioId, @PathVariable int dias) {
        List<ProductoDespensaDTO> productos = despensaService.obtenerProximosACaducar(usuarioId, dias);
        return ResponseEntity.ok(productos);
    }
}
