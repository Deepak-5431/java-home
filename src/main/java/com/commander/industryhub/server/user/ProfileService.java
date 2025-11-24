// all update regarding operations done here

package com.commander.industryhub.server.user;

import com.commander.industryhub.server.user.model.User;
import com.commander.industryhub.server.user.model.UserProfile;
import lombok.extern.slf4j.Slf4j;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Slf4j
@Service
@RequiredArgsConstructor

public class ProfileService {
    private final UserMapper userMapper;
    private  final UserRepository userRepository;

  @Transactional
  public UserProfile createUserProfile(User user) {
      UserProfile profile = new UserProfile(user);
      // Set default display name to username
      profile.setDisplayName(user.getUsername());
      log.info("Created profile for user: {}", user.getUsername());
      return profile;
  }
}
