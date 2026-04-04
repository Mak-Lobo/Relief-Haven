import React from "react";
import {Link} from "react-router-dom";
import styles from "./../../styles/register.module.css";

const Registration = () => {
    return (
        <div className={styles["main"]}>
            <div className={styles["reg-image"]}>
                <img src="/relief-haven-high-resolution-logo.png" alt="Relief Haven Logo"/>
            </div>

            <section className={styles["register-section"]}>
                <h1>Welcome to Relief Haven. Register to get started.</h1>

                <div className={styles['disclaimer']}>Ensure the email used is provided for by the government or any
                    organization authorized to use the
                    platform.
                </div>

                <div className={styles["form-container"]}>
                    <div className={styles["form"]}>
                        <div className={styles['names']}>
                            <input type="text" placeholder="Enter first name"/>
                            <input type="text" placeholder="Enter last name"/>
                        </div>
                        <div className={styles['num-email']}>
                            <input type="tel" placeholder="Enter phone number"/>
                            <input type="email" placeholder="Enter email"/>
                        </div>

                        <select defaultValue="">
                            <option value="" disabled>
                                Select county of work
                            </option>
                            <option value="nairobi">Nairobi</option>
                            <option value="mombasa">Mombasa</option>
                            <option value="kisumu">Kisumu</option>
                            <option value="nakuru">Nakuru</option>
                            <option value="Kiambu">Kiambu</option>
                        </select>

                        <select defaultValue="">
                            <option value="" disabled>
                                Select role
                            </option>
                            <option value="volunteer">Volunteer</option>
                            <option value="coordinator">Coordinator</option>
                            <option value="health-worker">Health Worker</option>
                            <option value="administrator">Administrator</option>
                        </select>

                        <input type="password" placeholder="Enter password"/>
                        <input type="password" placeholder="Reenter password"/>
                        <button>Create account</button>
                    </div>

                    <p className={styles["login"]}>
                        Already have an account? Click {' '}
                        <Link to="/login" className={styles["login-link"]}>
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
