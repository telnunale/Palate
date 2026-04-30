package palate_backend.service;

import palate_backend.dto.AlimentoDTO;
import palate_backend.dto.ProductoDespensaDTO;
import palate_backend.model.Alimento;
import palate_backend.model.ProductoDespensa;
import palate_backend.model.Usuario;
import palate_backend.repository.AlimentoRepository;
import palate_backend.repository.ProductoDespensaRepository;
import palate_backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class DespensaServiceImpl implements DespensaService {

    private final ProductoDespensaRepository productoDespensaRepository;
    private final UsuarioRepository usuarioRepository;
    private final AlimentoRepository alimentoRepository;

    @Autowired
    public DespensaServiceImpl(ProductoDespensaRepository productoDespensaRepository,
                                UsuarioRepository usuarioRepository,
                                AlimentoRepository alimentoRepository) {
        this.productoDespensaRepository = productoDespensaRepository;
        this.usuarioRepository = usuarioRepository;
        this.alimentoRepository = alimentoRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductoDespensaDTO> obtenerPorUsuario(Long usuarioId) {
        List<ProductoDespensa> productos = productoDespensaRepository.findByUsuarioIdAndConsumidoFalse(usuarioId);
        List<ProductoDespensaDTO> resultado = new ArrayList<>();
        for (ProductoDespensa p : productos) {
            resultado.add(productoToDTO(p));
        }
        return resultado;
    }

    @Override
    @Transactional
    public ProductoDespensaDTO añadir(Long usuarioId, Long alimentoId, LocalDate fechaCaducidad, BigDecimal cantidad, String unidad) {
        Optional<Usuario> usuario = usuarioRepository.findById(usuarioId);
        Optional<Alimento> alimento = alimentoRepository.findById(alimentoId);

        if (usuario.isEmpty() || alimento.isEmpty()) {
            throw new IllegalArgumentException("Usuario o alimento no encontrado");
        }

        ProductoDespensa producto = new ProductoDespensa(usuario.get(), alimento.get(), fechaCaducidad, cantidad, unidad);
        producto = productoDespensaRepository.save(producto);
        return productoToDTO(producto);
    }

    @Override
    @Transactional
    public ProductoDespensaDTO actualizar(Long id, Map<String, Object> datos) {
        ProductoDespensa producto = productoDespensaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Producto de despensa no encontrado"));

        if (datos.containsKey("alimentoId")) {
            Long alimentoId = Long.valueOf(datos.get("alimentoId").toString());
            Alimento alimento = alimentoRepository.findById(alimentoId)
                    .orElseThrow(() -> new IllegalArgumentException("Alimento no encontrado"));
            producto.setAlimento(alimento);
        }
        if (datos.containsKey("fechaCaducidad")) {
            producto.setFechaCaducidad(LocalDate.parse(datos.get("fechaCaducidad").toString()));
        }
        if (datos.containsKey("cantidad")) {
            producto.setCantidad(new BigDecimal(datos.get("cantidad").toString()));
        }
        if (datos.containsKey("unidad")) {
            producto.setUnidad((String) datos.get("unidad"));
        }
        if (datos.containsKey("consumido")) {
            producto.setConsumido(Boolean.parseBoolean(datos.get("consumido").toString()));
        }

        producto = productoDespensaRepository.save(producto);
        return productoToDTO(producto);
    }

    @Override
    @Transactional
    public void eliminar(Long id) {
        productoDespensaRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductoDespensaDTO> obtenerProximosACaducar(Long usuarioId, int dias) {
        LocalDate fechaLimite = LocalDate.now().plusDays(dias);
        List<ProductoDespensa> productos = productoDespensaRepository.buscarProximosACaducar(usuarioId, fechaLimite);
        List<ProductoDespensaDTO> resultado = new ArrayList<>();
        for (ProductoDespensa p : productos) {
            resultado.add(productoToDTO(p));
        }
        return resultado;
    }

    private ProductoDespensaDTO productoToDTO(ProductoDespensa p) {
        ProductoDespensaDTO dto = new ProductoDespensaDTO();
        dto.setId(p.getId());
        dto.setFechaCaducidad(p.getFechaCaducidad());
        dto.setCantidad(p.getCantidad());
        dto.setUnidad(p.getUnidad());
        dto.setConsumido(p.isConsumido());
        dto.setCreatedAt(p.getCreatedAt());

        if (p.getAlimento() != null) {
            AlimentoDTO alimentoDTO = new AlimentoDTO();
            alimentoDTO.setId(p.getAlimento().getId());
            alimentoDTO.setNombre(p.getAlimento().getNombre());
            alimentoDTO.setCategoria(p.getAlimento().getCategoria());
            alimentoDTO.setImagenUrl(p.getAlimento().getImagenUrl());
            dto.setAlimento(alimentoDTO);
        }

        return dto;
    }
}
