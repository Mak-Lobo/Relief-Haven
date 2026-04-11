import {Link} from 'react-router-dom';
import styles from '../styles/skeleton.module.css';
import {MdDashboard, MdHome, MdMoney, MdMessage} from 'react-icons/md';
import compass from '../assets/compass.png';
import '../App.css'

export const Navigation = () => {
    return (
        <div className={styles['navBlock']}>
            <div className={styles.logo}>
                <img className="compass" src={compass} alt="Relief Haven Logo"/>
                <span className={styles.logoText}>Relief Haven</span>
            </div>
            <nav className={styles.nav}>
                <ul className={styles.navList}>
                    <li><Link className={`${styles.navLink} ${styles.navLinkActive}`} to="/"><MdDashboard/>Home</Link>
                    </li>
                    <li><Link className={styles.navLink} to=" "><MdHome/>Shelters</Link></li>
                    <li><Link className={styles.navLink} to=" "><MdMoney/>Financials</Link></li>
                    <li><Link className={styles.navLink} to=" "><MdMessage/>Messages</Link></li>
                </ul>
            </nav>
        </div>
    )
}
