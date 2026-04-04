import React from "react";
import styles from './../../styles/login.module.css';
import {Link} from "react-router-dom";

export const Login = () => {
    return (
        <div className={styles['main']}>

            {/* Left — Logo */}
            <div className={styles['reg-image']}>
                <img src="/relief-haven-high-resolution-logo.png" alt="Relief Haven Logo"/>
            </div>

            {/* Right — Form */}
            <section className={styles['login-section']}>
                <h1>Welcome back. Login in to continue.</h1>

                <div className={styles['form-container']}>
                    <div className={styles['form']}>
                        <input type="email" placeholder="Enter email"/>
                        <input type="password" placeholder="Enter password"/>
                        <p>Forgot password?</p>
                        <button>Sign in</button>
                    </div>

                    <div className={styles['register']}>
                        Don't have an account? Click{' '}
                        <Link to='/register' className={styles['register-link']}>here</Link>
                        {' '}to continue.
                    </div>
                </div>

            </section>
        </div>
    );
};
