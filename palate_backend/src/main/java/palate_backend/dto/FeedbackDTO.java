package palate_backend.dto;


public class FeedbackDTO {


    private Long intoleranciaId;

    private boolean tolerado;

    public FeedbackDTO() {}

    public Long getIntoleranciaId() { return intoleranciaId; }
    public void setIntoleranciaId(Long intoleranciaId) { this.intoleranciaId = intoleranciaId; }

    public boolean isTolerado() { return tolerado; }
    public void setTolerado(boolean tolerado) { this.tolerado = tolerado; }
}
