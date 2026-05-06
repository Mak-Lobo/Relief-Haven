import {NavLink} from "react-router-dom";
import {MdDashboard, MdHome, MdMessage, MdMoney, MdLogout} from "react-icons/md";
import compass from "../assets/compass.png";
import styles from "../styles/skeleton.module.css";
import "../App.css";
import {useAuth} from "../context/AuthContext.jsx";

export const Navigation = () => {


    return (
        <aside className={styles["navBlock"]}>
            <div className={styles.logo}>
                <img className="compass" src={compass} alt="Relief Haven Logo"/>
                <span className={styles.logoText}>Relief Haven</span>
            </div>
            <nav className={styles.nav}>
                <ul className={styles.navList}>
                    <li>
                        <NavLink
                            to="/"
                            end
                            className={({isActive}) => isActive ? `${styles.navLink} ${styles.navLinkActive}` : styles.navLink}
                        >
                            <MdDashboard/>
                            <span>Home</span>
                        </NavLink>
                    </li>
                    <li>
                        <NavLink
                            to="/shelters"
                            className={({isActive}) => isActive ? `${styles.navLink} ${styles.navLinkActive}` : styles.navLink}
                        >
                            <MdHome/>
                            <span>Shelters</span>
                        </NavLink>
                    </li>
                    <li>
                        <NavLink
                            to="/financials"
                            className={({isActive}) => isActive ? `${styles.navLink} ${styles.navLinkActive}` : styles.navLink}
                        >
                            <MdMoney/>
                            <span>Financials</span>
                        </NavLink>
                    </li>
                    <li>
                        <span className={styles.navLink}>
                            <MdMessage/>
                            <span>Messages</span>
                        </span>
                    </li>
                </ul>
            </nav>
        </aside>
    );
};
