package com.commander.industryhub.server.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterUserRequest {

    // more validation checks are needed here maybe in future i will
    @NotBlank(message = "username cant be blank")
    @Size(min = 3,max = 50,message = "usename between 4 nd 40")
    private String username;


    @NotBlank(message = "buddy its email dont leave it empty")
    @Size(min = 11,max = 40,message = "dont play with system giving wrong email")
    private String email;

    @NotBlank(message = "think carefully before entering")
    @Size(min = 8, message = "minimum length is 8 digit")
    private String password;
}
