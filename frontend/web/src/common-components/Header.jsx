import React from "react";
import {Link, useLocation} from "react-router-dom";
import {MdPerson} from "react-icons/md";
import styles from "../styles/skeleton.module.css";
import {useAuth} from "../context/AuthContext.jsx";

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
    const {user, profile} = useAuth();
    const currentPage = breadcrumbMap[pathname] ?? "Dashboard";

    // Get display name from profile or email
    const getDisplayName = () => {
        if (profile?.first_name || profile?.last_name) {
            return [profile.first_name, profile.last_name].filter(Boolean).join(" ");
        }
        if (user?.email) {
            const namePart = user.email.split("@")[0];
            return namePart.replace(/[._]/g, " ");
        }
        return "Guest";
    };

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
                        <span>{getDisplayName()}</span>
                    </span>
            </Link>
        </header>
    );
};
