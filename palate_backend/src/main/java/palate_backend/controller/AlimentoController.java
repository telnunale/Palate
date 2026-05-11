package palate_backend.controller;

import palate_backend.dto.AlimentoDTO;
import palate_backend.model.Alimento;
import palate_backend.repository.AlimentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/alimentos")
public class AlimentoController {

    private final AlimentoRepository alimentoRepository;

    @Autowired
    public AlimentoController(AlimentoRepository alimentoRepository) {
        this.alimentoRepository = alimentoRepository;
    }

    @GetMapping
    public ResponseEntity<List<AlimentoDTO>> obtenerTodos() {
        List<Alimento> alimentos = alimentoRepository.findAll();
        List<AlimentoDTO> resultado = new ArrayList<>();
        for (Alimento a : alimentos) {
            resultado.add(toDTO(a));
        }
        return ResponseEntity.ok(resultado);
    }

    @PostMapping
    public ResponseEntity<Object> crearOObtener(@RequestBody Map<String, Object> datos) {
        String nombre = datos.get("nombre") != null ? datos.get("nombre").toString().trim() : "";
        String categoria = datos.get("categoria") != null && !datos.get("categoria").toString().isBlank()
                ? datos.get("categoria").toString().trim()
                : "Otros";

        if (nombre.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "El nombre del alimento no puede estar vacio");
            return ResponseEntity.badRequest().body(error);
        }

        Optional<Alimento> existente = alimentoRepository.findByNombreIgnoreCase(nombre);
        Alimento alimento = existente.orElseGet(() -> alimentoRepository.save(new Alimento(nombre, categoria)));
        return ResponseEntity.ok(toDTO(alimento));
    }

    private AlimentoDTO toDTO(Alimento a) {
        AlimentoDTO dto = new AlimentoDTO();
        dto.setId(a.getId());
        dto.setNombre(a.getNombre());
        dto.setCategoria(a.getCategoria());
        dto.setImagenUrl(a.getImagenUrl());
        return dto;
    }
}
