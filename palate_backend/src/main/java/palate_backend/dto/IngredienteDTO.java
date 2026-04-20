package palate_backend.dto;

import java.math.BigDecimal;

public class IngredienteDTO {

    private Long id;
    private AlimentoDTO alimento;
    private BigDecimal cantidad;
    private String unidadMedida;
    private String rol;
    private String metodoPreparacion;
    private boolean oculto;

    public IngredienteDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public AlimentoDTO getAlimento() { return alimento; }
    public void setAlimento(AlimentoDTO alimento) { this.alimento = alimento; }

    public BigDecimal getCantidad() { return cantidad; }
    public void setCantidad(BigDecimal cantidad) { this.cantidad = cantidad; }

    public String getUnidadMedida() { return unidadMedida; }
    public void setUnidadMedida(String unidadMedida) { this.unidadMedida = unidadMedida; }

    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }

    public String getMetodoPreparacion() { return metodoPreparacion; }
    public void setMetodoPreparacion(String metodoPreparacion) { this.metodoPreparacion = metodoPreparacion; }

    public boolean isOculto() { return oculto; }
    public void setOculto(boolean oculto) { this.oculto = oculto; }
}
