package palate_backend.dto;


public class MotivoRechazoDTO {

    private String tipo;

    private int intensidad;

    public MotivoRechazoDTO() {}

    public MotivoRechazoDTO(String tipo, int intensidad) {
        this.tipo = tipo;
        this.intensidad = intensidad;
    }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public int getIntensidad() { return intensidad; }
    public void setIntensidad(int intensidad) { this.intensidad = intensidad; }
}
