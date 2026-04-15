import common from "../../styles/views-common.module.css";
import styles from "../../styles/shelter-form.module.css";

const AddShelter = () => {
    return (
        <div className={common.pageStack}>
            <h1 className={common.pageTitle}>Register Shelter</h1>

            <div className={styles.formFrame}>
                <div className={styles.formCard}>
                    <h2 className={common.pageTitleCentered}>Shelter Registration</h2>

                    <form className={styles.formGrid}>
                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Shelter Name</span>
                            <input className={styles.textInput} type="text" />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>County</span>
                            <input className={styles.textInput} type="text" />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Location Coordinates</span>
                            <input className={styles.textInput} type="text" />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Subcounty</span>
                            <input className={styles.textInput} type="text" />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Occupants</span>
                            <input className={styles.textInput} type="number" />
                        </label>

                        <label className={styles.formField}>
                            <span className={common.fieldLabel}>Capacity</span>
                            <input className={styles.textInput} type="number" />
                        </label>
                    </form>

                    <div className={common.actionRowCentered}>
                        <button className={common.primaryActionWide} type="button">
                            Register Shelter
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AddShelter;
