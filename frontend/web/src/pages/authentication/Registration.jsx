import React, {useState} from "react";
import {Link} from "react-router-dom";
import styles from "./../../styles/auth.module.css";
import {SignUp} from "../../services/auth/SignUp";

const Registration = () => {
    const [formData, setFormData] = useState({
        firstName: "",
        lastName: "",
        phone: "",
        email: "",
        county: "",
        role: "",
        password: "",
        confirmPassword: "",
    });
    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleChange = (event) => {
        const {name, value} = event.target;

        setFormData((currentValues) => ({
            ...currentValues,
            [name]: value,
            ...(name === "role" && value !== "manager" ? {county: ""} : {}),
        }));
    };

    const handleSubmit = async (event) => {
        event.preventDefault();
        setErrorMessage("");
        setSuccessMessage("");

        const {
            firstName,
            lastName,
            phone,
            email,
            county,
            role,
            password,
            confirmPassword,
        } = formData;

        if (!firstName || !lastName || !phone || !email || !role || !password || !confirmPassword) {
            setErrorMessage("Please fill in all required fields.");
            return;
        }

        if (role === "manager" && !county) {
            setErrorMessage("Please select a county of work.");
            return;
        }

        if (!/^\d+$/.test(phone)) {
            setErrorMessage("Phone number must contain digits only.");
            return;
        }

        if (password !== confirmPassword) {
            setErrorMessage("Passwords do not match.");
            return;
        }

        setIsSubmitting(true);

        const result = await SignUp({
            firstName,
            lastName,
            phone,
            email,
            county,
            role,
            password,
        });

        setIsSubmitting(false);

        if (!result.success) {
            setErrorMessage(result.error || "Unable to create your account right now.");
            return;
        }

        setSuccessMessage("Account created successfully. You can now continue to login.");
        setFormData({
            firstName: "",
            lastName: "",
            phone: "",
            email: "",
            county: "",
            role: "",
            password: "",
            confirmPassword: "",
        });
    };

    return (
        <div className={styles["main"]}>
            <div className={styles["authImagePane"]}>
                <img
                    className={styles["authLogo"]}
                    src="/relief-haven-high-resolution-logo.png"
                    alt="Relief Haven Logo"
                />
            </div>

            <section className={styles["registerSection"]}>
                <h1 className={styles["heading"]}>Welcome to Relief Haven. Register to get started.</h1>

                <div className={styles["disclaimer"]}>Ensure the email used is provided for by the government or any
                    organization authorized to use the
                    platform.
                </div>

                <div className={styles["registerFormContainer"]}>
                    <form className={styles["registerForm"]} onSubmit={handleSubmit}>
                        <div className={styles["names"]}>
                            <input
                                type="text"
                                name="firstName"
                                placeholder="Enter first name"
                                value={formData.firstName}
                                onChange={handleChange}
                            />
                            <input
                                type="text"
                                name="lastName"
                                placeholder="Enter last name"
                                value={formData.lastName}
                                onChange={handleChange}
                            />
                        </div>
                        <div className={styles["numEmail"]}>
                            <input
                                type="tel"
                                name="phone"
                                placeholder="Enter phone number: 7** *** *** or 1** *** ***"
                                value={formData.phone}
                                onChange={handleChange}
                            />
                            <input
                                type="email"
                                name="email"
                                placeholder="Enter email"
                                value={formData.email}
                                onChange={handleChange}
                            />
                        </div>

                        <select name="role" value={formData.role} onChange={handleChange}>
                            <option value="" disabled>
                                Select role
                            </option>
                            <option value="manager">Manager</option>
                            <option value="command">Command</option>
                            <option value="civilian">Civilian</option>
                        </select>

                        <select
                            name="county"
                            value={formData.county}
                            onChange={handleChange}
                            disabled={formData.role !== "manager"}
                        >
                            <option value="" disabled>
                                {formData.role === "manager" ? "Select county of work" : "County only applies to managers"}
                            </option>
                            <option value="nairobi">Nairobi</option>
                            <option value="mombasa">Mombasa</option>
                            <option value="kisumu">Kisumu</option>
                            <option value="nakuru">Nakuru</option>
                            <option value="kiambu">Kiambu</option>
                        </select>

                        <input
                            type="password"
                            name="password"
                            placeholder="Enter password"
                            value={formData.password}
                            onChange={handleChange}
                        />
                        <input
                            type="password"
                            name="confirmPassword"
                            placeholder="Reenter password"
                            value={formData.confirmPassword}
                            onChange={handleChange}
                        />
                        {errorMessage ? (
                            <p style={{color: "var(--error, #b3261e)", margin: 0}}>{errorMessage}</p>
                        ) : null}
                        {successMessage ? (
                            <p style={{color: "var(--primary)", margin: 0}}>{successMessage}</p>
                        ) : null}
                        <button className={styles["submitButton"]} type="submit" disabled={isSubmitting}>
                            {isSubmitting ? "Creating account..." : "Create account"}
                        </button>
                    </form>

                    <p className={styles["loginPrompt"]}>
                        Already have an account? Click {' '}
                        <Link to="/login" className={styles["authLink"]}>
                            here
                        </Link> {' '}
                        to continue.
                    </p>
                </div>
            </section>
        </div>
    );
};
export default Registration
