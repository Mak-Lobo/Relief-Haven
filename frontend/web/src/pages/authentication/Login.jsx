import React, {useState} from "react";
import {Link, useNavigate} from "react-router-dom";
import styles from "./../../styles/auth.module.css";
import {signInUser} from "../../services/auth/SignIn";

export const Login = () => {
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        email: "",
        password: "",
    });
    const [errorMessage, setErrorMessage] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleChange = (event) => {
        const {name, value} = event.target;

        setFormData((currentValues) => ({
            ...currentValues,
            [name]: value,
        }));
    };

    const handleSubmit = async (event) => {
        event.preventDefault();
        setErrorMessage("");

        const {email, password} = formData;

        if (!email || !password) {
            setErrorMessage("Please enter both your email and password.");
            return;
        }

        setIsSubmitting(true);
        const result = await signInUser({email, password});
        setIsSubmitting(false);

        if (!result.success) {
            setErrorMessage(result.error || "Unable to sign you in right now.");
            return;
        }

        navigate("/");
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

            <section className={styles["loginSection"]}>
                <h1 className={styles["heading"]}>Welcome back. Login in to continue.</h1>

                <div className={styles["loginFormContainer"]}>
                    <form className={styles["loginForm"]} onSubmit={handleSubmit}>
                        <input
                            type="email"
                            name="email"
                            placeholder="Enter email"
                            value={formData.email}
                            onChange={handleChange}
                        />
                        <input
                            type="password"
                            name="password"
                            placeholder="Enter password"
                            value={formData.password}
                            onChange={handleChange}
                        />
                        <p className={styles["forgotPassword"]}>Forgot password?</p>
                        {errorMessage ? (
                            <p style={{color: "var(--error, #b3261e)", margin: 0}}>{errorMessage}</p>
                        ) : null}
                        <button className={styles["submitButton"]} type="submit" disabled={isSubmitting}>
                            {isSubmitting ? "Signing in..." : "Sign in"}
                        </button>
                    </form>

                    <div className={styles["registerPrompt"]}>
                        Don't have an account? Click{" "}
                        <Link to="/register" className={styles["authLink"]}>here</Link>
                        {" "}to continue.
                    </div>
                </div>

            </section>
        </div>
    );
};
