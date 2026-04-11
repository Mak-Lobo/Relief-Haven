import React from "react";
import {Link} from "react-router-dom";
import styles from "./../../styles/auth.module.css";

export const Login = () => {
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
                    <div className={styles["loginForm"]}>
                        <input type="email" placeholder="Enter email" />
                        <input type="password" placeholder="Enter password" />
                        <p className={styles["forgotPassword"]}>Forgot password?</p>
                        <button className={styles["submitButton"]}>Sign in</button>
                    </div>

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
