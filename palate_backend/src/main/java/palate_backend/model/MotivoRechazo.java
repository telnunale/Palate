package palate_backend.model;


import jakarta.persistence.*;
import palate_backend.enums.TipoMotivoRechazo;

@Entity
@Table(name = "motivo_rechazo",
        uniqueConstraints = @UniqueConstraint(columnNames = {"intolerancia_id", "tipo"}))
public class MotivoRechazo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;


    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "intolerancia_id", nullable = false)
    @com.fasterxml.jackson.annotation.JsonIgnore
    private IntoleranciaUsuario intolerancia;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false)
    private TipoMotivoRechazo tipo;

    @Column(name = "intensidad", nullable = false)
    private int intensidad;

    public MotivoRechazo() {
    }

    public MotivoRechazo(TipoMotivoRechazo tipo, int intensidad) {
        this.tipo = tipo;
        this.intensidad = intensidad;
    }

    public IntoleranciaUsuario getIntolerancia() {
        return intolerancia;
    }

    public void setIntolerancia(IntoleranciaUsuario intolerancia) {
        this.intolerancia = intolerancia;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public TipoMotivoRechazo getTipo() {
        return tipo;
    }

    public void setTipo(TipoMotivoRechazo tipo) {
        this.tipo = tipo;
    }

    public int getIntensidad() {
        return intensidad;
    }

    public void setIntensidad(int intensidad) {
        this.intensidad = intensidad;
    }

    @Override
    public String toString() {
        return "MotivoRechazo{" +
                "id=" + id +
                ", tipo=" + tipo +
                ", intensidad=" + intensidad +
                '}';
    }
}