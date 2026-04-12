package palate_backend.dao;

import palate_backend.model.Alimento;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Optional;

public class AlimentoDaoImpl implements AlimentoDao {

    private EntityManager em;

    public AlimentoDaoImpl(EntityManager em) {
        this.em = em;
    }

    @Override
    public boolean crearAlimento(Alimento alimento) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            em.persist(alimento);
            et.commit();
            return true;
        } catch (RuntimeException e) {
            if (et.isActive()) {
                et.rollback();
            }
            return false;
        }
    }

    @Override
    public Optional<Alimento> buscarPorID(long id) {
        Alimento a = em.find(Alimento.class, id);
        return Optional.ofNullable(a);
    }

    @Override
    public Alimento actualizarAlimento(Alimento alimento) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            Alimento a = em.merge(alimento);
            et.commit();
            return a;
        } catch (RuntimeException e) {
            if (et.isActive()) {
                et.rollback();
            }
            throw new RuntimeException(e.getMessage());
        }
    }

    @Override
    public boolean eliminarAlimento(Alimento alimento) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            Optional<Alimento> a = this.buscarPorID(alimento.getId());
            if (a.isPresent()) {
                em.remove(em.merge(alimento));
                et.commit();
                return true;
            }
            return false;
        } catch (RuntimeException e) {
            if (et.isActive()) {
                et.rollback();
            }
            return false;
        }
    }

    @Override
    public List<Alimento> recuperarTodos() {
        String jpql = "SELECT a FROM Alimento a";
        TypedQuery<Alimento> query = em.createQuery(jpql, Alimento.class);
        return query.getResultList();
    }

    @Override
    public Optional<Alimento> buscarPorNombre(String nombre) {
        String jpql = "SELECT a FROM Alimento a WHERE a.nombre = :nombreParam";
        TypedQuery<Alimento> query = em.createQuery(jpql, Alimento.class);
        query.setParameter("nombreParam", nombre);
        List<Alimento> resultados = query.getResultList();
        if (resultados.isEmpty()) {
            return Optional.empty();
        }
        return Optional.of(resultados.get(0));
    }

    @Override
    public List<Alimento> buscarPorCategoria(String categoria) {
        String jpql = "SELECT a FROM Alimento a WHERE a.categoria = :catParam";
        TypedQuery<Alimento> query = em.createQuery(jpql, Alimento.class);
        query.setParameter("catParam", categoria);
        return query.getResultList();
    }
}
