import {Outlet} from "react-router-dom";
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
                    <Outlet/>
                </section>
                <Footer/>
            </main>
        </div>
    );
};

export default Skeleton;
