package com.palate.dao;

import com.palate.model.RecetaAlimento;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Optional;

public class RecetaAlimentoDaoImpl implements RecetaAlimentoDao {

    private EntityManager em;

    public RecetaAlimentoDaoImpl(EntityManager em) {
        this.em = em;
    }

    @Override
    public boolean crearRecetaAlimento(RecetaAlimento recetaAlimento) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            em.persist(recetaAlimento);
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
    public Optional<RecetaAlimento> buscarPorID(long id) {
        RecetaAlimento ra = em.find(RecetaAlimento.class, id);
        return Optional.ofNullable(ra);
    }

    @Override
    public boolean eliminarRecetaAlimento(RecetaAlimento recetaAlimento) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            Optional<RecetaAlimento> ra = this.buscarPorID(recetaAlimento.getId());
            if (ra.isPresent()) {
                em.remove(em.merge(recetaAlimento));
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
    public List<RecetaAlimento> buscarPorReceta(long recetaId) {
        String jpql = "SELECT ra FROM RecetaAlimento ra " +
                       "JOIN FETCH ra.alimento " +
                       "WHERE ra.receta.id = :recetaIdParam";
        TypedQuery<RecetaAlimento> query = em.createQuery(jpql, RecetaAlimento.class);
        query.setParameter("recetaIdParam", recetaId);
        return query.getResultList();
    }

    @Override
    public List<RecetaAlimento> buscarPorAlimento(long alimentoId) {
        String jpql = "SELECT ra FROM RecetaAlimento ra " +
                       "JOIN FETCH ra.receta " +
                       "WHERE ra.alimento.id = :alimentoIdParam";
        TypedQuery<RecetaAlimento> query = em.createQuery(jpql, RecetaAlimento.class);
        query.setParameter("alimentoIdParam", alimentoId);
        return query.getResultList();
    }
}
