package com.palate.dao;

import com.palate.model.Usuario;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Optional;

public class UsuarioDaoImpl implements UsuarioDao {

    private EntityManager em;

    public UsuarioDaoImpl(EntityManager em) {
        this.em = em;
    }

    @Override
    public boolean crearUsuario(Usuario usuario) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            em.persist(usuario);
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
    public Optional<Usuario> buscarPorID(long id) {
        Usuario u = em.find(Usuario.class, id);
        return Optional.ofNullable(u);
    }

    @Override
    public Usuario actualizarUsuario(Usuario usuario) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            Usuario u = em.merge(usuario);
            et.commit();
            return u;
        } catch (RuntimeException e) {
            if (et.isActive()) {
                et.rollback();
            }
            throw new RuntimeException(e.getMessage());
        }
    }

    @Override
    public boolean eliminarUsuario(Usuario usuario) {
        EntityTransaction et = em.getTransaction();
        try {
            et.begin();
            Optional<Usuario> u = this.buscarPorID(usuario.getId());
            if (u.isPresent()) {
                em.remove(em.merge(usuario));
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
    public Optional<Usuario> buscarPorEmail(String email) {
        String jpql = "SELECT u FROM Usuario u WHERE u.email = :emailParam";
        TypedQuery<Usuario> query = em.createQuery(jpql, Usuario.class);
        query.setParameter("emailParam", email);
        List<Usuario> resultados = query.getResultList();
        if (resultados.isEmpty()) {
            return Optional.empty();
        }
        return Optional.of(resultados.get(0));
    }

    @Override
    public List<Usuario> recuperarTodos() {
        String jpql = "SELECT u FROM Usuario u";
        TypedQuery<Usuario> query = em.createQuery(jpql, Usuario.class);
        return query.getResultList();
    }
}
