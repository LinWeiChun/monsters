package com.monsters.repository.user;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.monsters.entity.user.User;

public interface UserRepository extends JpaRepository<User, Long> {

	boolean existsByEmail(String email);

	boolean existsByAccount(String account);

	Optional<User> findByEmail(String email);

	Optional<User> findByPublicId(String publicId);

	Optional<User> findByEmailAndDeletedFalse(String email);

	@Query("""
			    SELECT u
			    FROM User u
			    WHERE u.deleted = false
			      AND (
			          u.email = :email
			          OR u.account = :email
			      )
			""")
	Optional<User> findByEmailOrAccountAndDeletedFalse(@Param("email") String email);

	Optional<User> findByIdAndDeletedFalse(Long id);
}
