import {Header} from "../../common-components/Header";
import {Navigation} from "../../common-components/Navigation.jsx";
import {Footer} from "../../common-components/Footer.jsx";
import styles from "../../styles/skeleton.module.css";

const Skeleton = () => {
    return (
        <div className={styles.skeleton}>
            <Navigation/>
            <main className={styles.mainLayout}>
                <Header/>
                <section className={styles.contentArea}>
                    <div>Content goes here.</div>
                </section>
                <Footer/>
            </main>
        </div>
    );
};

export default Skeleton;
