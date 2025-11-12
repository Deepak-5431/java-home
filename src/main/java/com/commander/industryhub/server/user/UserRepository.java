//user repo main for database calling from backend

package com.commander.industryhub.server.user;

import com.commander.industryhub.server.user.model.UserStatus;
import com.commander.industryhub.server.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository //means it will talk to database only
public interface UserRepository extends JpaRepository<User,Long>{
 Optional<User> findByEmail(String email);
 Optional<User> findByUsername(String username);
 Optional<User> findByIdandStatus(Long id,String status);


 boolean existsByEmail(String email);
 boolean existsByUsername(String username);

//annotation to define custom query using jpa usimple could be made better
 @Query(value="SELECT * FROM users u WHERE " +
         "u.username ILIKE CONCAT('%', :query ,'%') OR " +
         "u.email ILIKE CONCAT('%', :query ,'%')",
         nativeQuery = true)
 List<User> searchUsersBy(@Param("query") String query);
}
