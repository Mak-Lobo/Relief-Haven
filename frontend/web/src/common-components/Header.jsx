import React from "react";
import styles from "../styles/skeleton.module.css";
import {FaPerson} from "react-icons/fa6";

export const Header = () => {
    return (
        <header>
            <div className={styles.breadcrumbs} aria-label="Breadcrumb">
                <span>Home</span>
                <span>/</span>
                <span>Dashboard</span>
            </div>

            <button className={styles.accountButton} type="button">
                <span className={styles.accountText}>
                    <FaPerson />
                    <span>Mark Njoroge</span>
                </span>
            </button>
        </header>
    );
};
