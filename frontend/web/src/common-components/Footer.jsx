import styles from "../styles/skeleton.module.css";
import {FaEnvelope, FaFacebook, FaTwitter} from "react-icons/fa";

export const Footer = () => {
    return (
        <footer>
            <div className={styles.socialMedia}>
                <div className={styles.socialItem}>
                    <FaFacebook style={{width: 20, height: 20}}></FaFacebook>
                    <span>facebook.com/reliefhaven</span>
                </div>
                <div className={styles.socialItem}>
                    <FaTwitter style={{width: 20, height: 20}}></FaTwitter>
                    <span>twitter.com/reliefhaven</span>
                </div>
                <div className={styles.socialItem}>
                    <FaEnvelope style={{width: 20, height: 20}}></FaEnvelope>
                    <span>gmail.com/reliefhaven</span>
                </div>
            </div>

            <span className={styles.footerText}>2026. Terms and Conditions Apply.</span>
            <span className={styles.footerText}>Privacy Policy Guide</span>
        </footer>
    )
}
