package palate_backend.service;

import palate_backend.dto.AlimentoDTO;
import palate_backend.dto.IntoleranciaDTO;
import palate_backend.dto.MotivoRechazoDTO;
import palate_backend.enums.TipoMotivoRechazo;
import palate_backend.model.*;
import palate_backend.repository.AlimentoRepository;
import palate_backend.repository.IntoleranciaUsuarioRepository;
import palate_backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class IntoleranciaServiceImpl implements IntoleranciaService {

    private final IntoleranciaUsuarioRepository intoleranciaRepository;
    private final UsuarioRepository usuarioRepository;
    private final AlimentoRepository alimentoRepository;

    @Autowired
    public IntoleranciaServiceImpl(IntoleranciaUsuarioRepository intoleranciaRepository,
                                   UsuarioRepository usuarioRepository,
                                   AlimentoRepository alimentoRepository) {
        this.intoleranciaRepository = intoleranciaRepository;
        this.usuarioRepository = usuarioRepository;
        this.alimentoRepository = alimentoRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<IntoleranciaDTO> obtenerPorUsuario(Long usuarioId) {
        List<IntoleranciaUsuario> intolerancias = intoleranciaRepository.findByUsuarioId(usuarioId);
        List<IntoleranciaDTO> resultado = new ArrayList<>();
        for (IntoleranciaUsuario i : intolerancias) {
            resultado.add(intoleranciaToDTO(i));
        }
        return resultado;
    }

    @Override
    @Transactional
    public void crear(Long usuarioId, Long alimentoId, int nivelRechazo, List<Map<String, Object>> motivos) {
        Optional<Usuario> usuario = usuarioRepository.findById(usuarioId);
        Optional<Alimento> alimento = alimentoRepository.findById(alimentoId);

        if (usuario.isEmpty() || alimento.isEmpty()) {
            throw new IllegalArgumentException("Usuario o alimento no encontrado");
        }

        IntoleranciaUsuario intolerancia = new IntoleranciaUsuario(usuario.get(), alimento.get(), nivelRechazo);

        if (motivos != null) {
            for (Map<String, Object> motivoMap : motivos) {
                String tipo = (String) motivoMap.get("tipo");
                int intensidad = Integer.parseInt(motivoMap.get("intensidad").toString());
                intolerancia.addMotivo(new MotivoRechazo(TipoMotivoRechazo.valueOf(tipo), intensidad));
            }
        }

        intoleranciaRepository.save(intolerancia);
    }

    @Override
    @Transactional
    public void actualizar(Long id, int nivelRechazo, List<Map<String, Object>> motivos) {
        IntoleranciaUsuario intolerancia = intoleranciaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Aversion no encontrada"));

        intolerancia.setNivelRechazo(nivelRechazo);

        intolerancia.getMotivos().clear();
        if (motivos != null) {
            for (Map<String, Object> motivoMap : motivos) {
                String tipo = (String) motivoMap.get("tipo");
                int intensidad = Integer.parseInt(motivoMap.get("intensidad").toString());
                intolerancia.addMotivo(new MotivoRechazo(TipoMotivoRechazo.valueOf(tipo), intensidad));
            }
        }

        intoleranciaRepository.save(intolerancia);
    }

    @Override
    @Transactional
    public void eliminar(Long id) {
        intoleranciaRepository.deleteById(id);
    }

    @Override
    @Transactional
    public IntoleranciaDTO registrarFeedback(Long intoleranciaId, boolean tolerado) {
        IntoleranciaUsuario intolerancia = intoleranciaRepository.findById(intoleranciaId)
                .orElseThrow(() -> new IllegalArgumentException("Aversion no encontrada"));

        int progresoActual = intolerancia.getNivelProgreso();
        int nuevoProgreso;
        if (tolerado) {
            nuevoProgreso = Math.min(progresoActual + 1, 10);
        } else {
            nuevoProgreso = Math.max(progresoActual - 1, 0);
        }

        intolerancia.setNivelProgreso(nuevoProgreso);

        if (nuevoProgreso >= intolerancia.getNivelRechazo()) {
            intolerancia.setSuperada(true);
        }

        intoleranciaRepository.save(intolerancia);
        return intoleranciaToDTO(intolerancia);
    }

    private IntoleranciaDTO intoleranciaToDTO(IntoleranciaUsuario i) {
        IntoleranciaDTO dto = new IntoleranciaDTO();
        dto.setId(i.getId());
        dto.setNivelRechazo(i.getNivelRechazo());
        dto.setNivelProgreso(i.getNivelProgreso());
        dto.setSuperada(i.isSuperada());
        dto.setFechaRegistro(i.getFechaRegistro());

        if (i.getAlimento() != null) {
            AlimentoDTO alimentoDTO = new AlimentoDTO();
            alimentoDTO.setId(i.getAlimento().getId());
            alimentoDTO.setNombre(i.getAlimento().getNombre());
            alimentoDTO.setCategoria(i.getAlimento().getCategoria());
            alimentoDTO.setImagenUrl(i.getAlimento().getImagenUrl());
            dto.setAlimento(alimentoDTO);
        }

        List<MotivoRechazoDTO> motivosDTO = new ArrayList<>();
        for (MotivoRechazo m : i.getMotivos()) {
            motivosDTO.add(new MotivoRechazoDTO(m.getTipo().name(), m.getIntensidad()));
        }
        dto.setMotivos(motivosDTO);

        return dto;
    }
}
