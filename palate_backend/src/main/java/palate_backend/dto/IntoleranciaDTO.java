package palate_backend.dto;

import java.time.LocalDate;

public class IntoleranciaDTO {

    private Long id;
    private AlimentoDTO alimento;
    private int nivelRechazo;
    private int nivelProgreso;
    private LocalDate fechaRegistro;

    public IntoleranciaDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public AlimentoDTO getAlimento() { return alimento; }
    public void setAlimento(AlimentoDTO alimento) { this.alimento = alimento; }

    public int getNivelRechazo() { return nivelRechazo; }
    public void setNivelRechazo(int nivelRechazo) { this.nivelRechazo = nivelRechazo; }

    public int getNivelProgreso() { return nivelProgreso; }
    public void setNivelProgreso(int nivelProgreso) { this.nivelProgreso = nivelProgreso; }

    public LocalDate getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(LocalDate fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}
