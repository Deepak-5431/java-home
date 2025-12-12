package com.commander.industryhub.server.user;

import com.commander.industryhub.server.user.dto.*;
import com.commander.industryhub.server.user.model.User;
import com.commander.industryhub.server.user.model.UserStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final ProfileService profileService;
    private final UserMapper userMapper;

    public List<UserDto> getAllUsers() {
        return userRepository.findAll().stream()
                .map(userMapper::toUserDto)
                .toList();
    }

    public Optional<UserResponseDto> getUserById(Long id) {
        return userRepository.findById(id)
                .map(userMapper::toUserResponseDto);
    }

    public Optional<UserDto> getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(userMapper::toUserDto);
    }

    public Optional<UserDto> getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .map(userMapper::toUserDto);
    }

    public List<UserDto> searchUsers(String query) {
        return userRepository.searchUsersBy(query).stream()
                .map(userMapper::toUserDto)
                .toList();
    }

    public List<UserDto> getUsersByStatus(UserStatus status) {
        return userRepository.findByStatus(status).stream()
                .map(userMapper::toUserDto)
                .toList();
    }

    @Transactional
    public UserResponseDto createUser(RegisterUserRequest request) {
        // Validate unique constraints
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists: " + request.getEmail());
        }
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists: " + request.getUsername());
        }

        // Convert DTO → Entity
        User user = userMapper.toEntity(request);
        user.setStatus(UserStatus.ACTIVE);
        user.setCreatedAt(Instant.now());
        user.setUpdatedAt(Instant.now());

        User savedUser = userRepository.save(user);

        // Create profile for new user
        profileService.createUserProfile(savedUser);

        log.info("Created new user: {} with email: {}", savedUser.getUsername(), savedUser.getEmail());
        return userMapper.toUserResponseDto(savedUser);
    }

    @Transactional
    public UserDto updateUser(Long userId, UpdateUserRequest request) {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        // Update using mapper
        userMapper.updateUserFromRequest(request, existingUser);
        existingUser.setUpdatedAt(Instant.now());

        User updatedUser = userRepository.save(existingUser);
        log.info("Updated user: {}", updatedUser.getUsername());
        return userMapper.toUserDto(updatedUser);
    }

    @Transactional
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        user.setStatus(UserStatus.DELETED);
        user.setUpdatedAt(Instant.now());
        userRepository.save(user);

        log.info("Soft deleted user: {}", user.getUsername());
    }

    @Transactional
    public void updateLoginSuccess(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        user.setLastLoginAt(Instant.now());
        user.setLoginAttempts(0);
        user.setUpdatedAt(Instant.now());
        userRepository.save(user);
    }

    @Transactional
    public void incrementLoginAttempts(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        user.setLoginAttempts(user.getLoginAttempts() + 1);
        user.setUpdatedAt(Instant.now());
        userRepository.save(user);
    }

    public long getActiveUsersCount() {
        return userRepository.countByStatus(UserStatus.ACTIVE);
    }
}