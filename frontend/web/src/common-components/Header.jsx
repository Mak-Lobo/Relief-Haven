import React from "react";
import {Link, useLocation} from "react-router-dom";
import {MdPerson} from "react-icons/md";
import styles from "../styles/skeleton.module.css";

const breadcrumbMap = {
    "/": "Dashboard",
    "/shelters": "Shelters",
    "/shelters/add": "Register Shelter",
    "/shelters/update": "Update shelter",
    "/financials": "Financials",
    "/profile": "Account",
};

export const Header = () => {
    const {pathname} = useLocation();
    const currentPage = breadcrumbMap[pathname] ?? "Dashboard";

    return (
        <header>
            <div className={styles.breadcrumbs} aria-label="Breadcrumb">
                <span>Home</span>
                <span>/</span>
                <span>{currentPage}</span>
            </div>

            <Link className={styles.accountButton} to="/profile">
                <span className={styles.accountText}>
                    <MdPerson/>
                    <span>Mark Njoroge</span>
                </span>
            </Link>
        </header>
    );
};
