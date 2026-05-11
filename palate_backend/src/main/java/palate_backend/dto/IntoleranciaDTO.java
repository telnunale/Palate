package palate_backend.dto;

import java.time.LocalDate;
import java.util.List;

public class IntoleranciaDTO {

    private Long id;
    private AlimentoDTO alimento;
    private int nivelRechazo;
    private int nivelProgreso;
    private boolean superada;
    private LocalDate fechaRegistro;

    private List<MotivoRechazoDTO> motivos;

    public IntoleranciaDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public AlimentoDTO getAlimento() { return alimento; }
    public void setAlimento(AlimentoDTO alimento) { this.alimento = alimento; }

    public int getNivelRechazo() { return nivelRechazo; }
    public void setNivelRechazo(int nivelRechazo) { this.nivelRechazo = nivelRechazo; }

    public int getNivelProgreso() { return nivelProgreso; }
    public void setNivelProgreso(int nivelProgreso) { this.nivelProgreso = nivelProgreso; }

    public boolean isSuperada() { return superada; }
    public void setSuperada(boolean superada) { this.superada = superada; }

    public LocalDate getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(LocalDate fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public List<MotivoRechazoDTO> getMotivos() { return motivos; }
    public void setMotivos(List<MotivoRechazoDTO> motivos) { this.motivos = motivos; }
}
