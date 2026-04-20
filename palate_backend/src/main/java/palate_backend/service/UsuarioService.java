package palate_backend.service;

import palate_backend.dto.UsuarioDTO;

import java.util.Optional;

public interface UsuarioService {

    UsuarioDTO registro(String email, String password, String nombre);

    Optional<UsuarioDTO> login(String email, String password);
}
