package palate_backend.model;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "intolerancia_usuario", uniqueConstraints = @UniqueConstraint(columnNames = {"usuario_id", "alimento_id"}))
public class IntoleranciaUsuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    @com.fasterxml.jackson.annotation.JsonIgnore
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "alimento_id", nullable = false)
    private Alimento alimento;

    @Column(name = "nivel_rechazo", nullable = false)
    private int nivelRechazo;

    @Column(name = "nivel_progreso", nullable = false)
    private int nivelProgreso = 0;

    @Column(name = "fecha_registro", nullable = false)
    private LocalDate fechaRegistro;

    @Column(name = "ultima_actualizacion", nullable = false)
    private LocalDate ultimaActualizacion;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @JoinColumn(name = "intolerancia_id")
    private List<MotivoRechazo> motivos = new ArrayList<>();

    public IntoleranciaUsuario() {
    }

    public IntoleranciaUsuario(Usuario usuario, Alimento alimento, int nivelRechazo) {
        this.usuario = usuario;
        this.alimento = alimento;
        this.nivelRechazo = nivelRechazo;
    }

    @PrePersist
    protected void onCreate() {
        this.fechaRegistro = LocalDate.now();
        this.ultimaActualizacion = LocalDate.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public Alimento getAlimento() {
        return alimento;
    }

    public void setAlimento(Alimento alimento) {
        this.alimento = alimento;
    }

    public int getNivelRechazo() {
        return nivelRechazo;
    }

    public void setNivelRechazo(int nivelRechazo) {
        this.nivelRechazo = nivelRechazo;
    }

    public int getNivelProgreso() {
        return nivelProgreso;
    }

    public void setNivelProgreso(int nivelProgreso) {
        this.nivelProgreso = nivelProgreso;
    }

    public LocalDate getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDate fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public LocalDate getUltimaActualizacion() {
        return ultimaActualizacion;
    }

    public void setUltimaActualizacion(LocalDate ultimaActualizacion) {
        this.ultimaActualizacion = ultimaActualizacion;
    }

    public List<MotivoRechazo> getMotivos() {
        return motivos;
    }

    public void setMotivos(List<MotivoRechazo> motivos) {
        this.motivos = motivos;
    }

    @Override
    public String toString() {
        return "IntoleranciaUsuario{" +
                "id=" + id +
                ", alimento=" + (alimento != null ? alimento.getNombre() : "null") +
                ", nivelRechazo=" + nivelRechazo +
                ", nivelProgreso=" + nivelProgreso +
                ", fechaRegistro=" + fechaRegistro +
                '}';
    }
}