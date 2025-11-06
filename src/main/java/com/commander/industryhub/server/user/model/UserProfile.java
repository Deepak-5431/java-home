package com.commander.industryhub.server.user.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.Instant;
import java.time.LocalDate;


@Entity
@Table(name = "user_profiles")
@Getter
@Setter
public class UserProfile {
    @Id
    private Long userId;

    @OneToOne
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    // Personal information
    @Column(name = "first_name", length = 100)
    private String firstName;

    @Column(name = "last_name", length = 100)
    private String lastName;

    @Column(name = "display_name", length = 100)
    private String displayName;

    // Profile information
    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "cover_image_url")
    private String coverImageUrl;

    // Personal details
    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "location", length = 100)
    private String location;

    @Column(name = "website", length = 255)
    private String website;

    @Column(name = "company", length = 100)
    private String company;

    @Column(name = "job_title", length = 100)
    private String jobTitle;

    // Social metrics
    @Column(name = "follower_count", nullable = false)
    private Integer followerCount = 0;

    @Column(name = "following_count", nullable = false)
    private Integer followingCount = 0;

    // Timestamps
    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    // Constructors
    public UserProfile() {}

    public UserProfile(User user) {
        this.user = user;
        this.userId = user.getId();
    }

}
