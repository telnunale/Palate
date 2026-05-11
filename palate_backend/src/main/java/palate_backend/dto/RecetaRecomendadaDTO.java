package palate_backend.dto;

public class RecetaRecomendadaDTO extends RecetaDTO {


    private int score;

    private String motivoRecomendacion;

    public RecetaRecomendadaDTO() {}

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public String getMotivoRecomendacion() { return motivoRecomendacion; }
    public void setMotivoRecomendacion(String motivoRecomendacion) {
        this.motivoRecomendacion = motivoRecomendacion;
    }
}
