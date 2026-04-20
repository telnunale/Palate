package palate_backend.service;

import palate_backend.dto.UsuarioDTO;
import palate_backend.model.Usuario;
import palate_backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class UsuarioServiceImpl implements UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public UsuarioServiceImpl(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public UsuarioDTO registro(String email, String password, String nombre) {
        if (usuarioRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("El email ya está registrado");
        }
        Usuario usuario = new Usuario(email, passwordEncoder.encode(password), nombre);
        return usuarioToDTO(usuarioRepository.save(usuario));
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<UsuarioDTO> login(String email, String password) {
        Optional<Usuario> resultado = usuarioRepository.findByEmail(email);
        if (resultado.isEmpty()) {
            return Optional.empty();
        }
        Usuario usuario = resultado.get();
        if (!passwordEncoder.matches(password, usuario.getPasswordHash())) {
            return Optional.empty();
        }
        return Optional.of(usuarioToDTO(usuario));
    }

    private UsuarioDTO usuarioToDTO(Usuario u) {
        UsuarioDTO dto = new UsuarioDTO();
        dto.setId(u.getId());
        dto.setEmail(u.getEmail());
        dto.setNombre(u.getNombre());
        dto.setAvatarUrl(u.getAvatarUrl());
        dto.setCreatedAt(u.getCreatedAt());
        return dto;
    }
}
