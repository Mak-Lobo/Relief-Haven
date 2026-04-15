import {useState} from "react";
import Slider from "rc-slider";
import "rc-slider/assets/index.css";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/shelter-form.module.css";

const sliderTheme = {
    trackStyle: {backgroundColor: "var(--primary)", height: 8},
    railStyle: {backgroundColor: "var(--primary-container)", height: 8},
    handleStyle: {
        borderColor: "var(--secondary)",
        backgroundColor: "var(--secondary)",
        opacity: 1,
        width: 16,
        height: 16,
        marginTop: -4,
    },
};

const UpdateShelter = () => {
    const [occupancy, setOccupancy] = useState(75);
    const [food, setFood] = useState(50);
    const [water, setWater] = useState(50);
    const [medicine, setMedicine] = useState(50);

    return (
        <div className={common.pageStack}>
            <h1 className={common.pageTitle}>Update Shelter: Thika Stadium</h1>

            <div className={styles.formFrame}>
                <div className={styles.formCard}>
                    <h2 className={common.pageTitleCentered}>Thika Stadium</h2>

                    <div className={styles.sliderGroup}>
                        <div className={styles.sliderHeaderRow}>
                            <h3 className={styles.sliderSectionTitle}>Occupancy Update</h3>
                            <div className={styles.sliderPillMeta}>
                                <span className={styles.sliderMeta}>75/250 people</span>
                                <div className={styles.valuePill}>{occupancy}</div>
                            </div>
                        </div>
                        <Slider min={0} max={250} value={occupancy} onChange={setOccupancy} {...sliderTheme} />
                    </div>

                    <div className={styles.sliderGroup}>
                        <h3 className={styles.sliderSectionTitle}>Resource Inventory</h3>

                        <div className={styles.sliderRow}>
                            <div className={styles.sliderField}>
                                <span className={common.fieldLabel}>Food Resource (%)</span>
                                <Slider min={0} max={100} value={food} onChange={setFood} {...sliderTheme} />
                            </div>
                            <div className={styles.valuePillGroup}>
                                <div className={styles.valuePill}>{food}</div>
                                <span className={styles.valueUnit}>%</span>
                            </div>
                        </div>

                        <div className={styles.sliderRow}>
                            <div className={styles.sliderField}>
                                <span className={common.fieldLabel}>Water Resource (%)</span>
                                <Slider min={0} max={100} value={water} onChange={setWater} {...sliderTheme} />
                            </div>
                            <div className={styles.valuePillGroup}>
                                <div className={styles.valuePill}>{water}</div>
                                <span className={styles.valueUnit}>%</span>
                            </div>
                        </div>

                        <div className={styles.sliderRow}>
                            <div className={styles.sliderField}>
                                <span className={common.fieldLabel}>Medicine Resource (%)</span>
                                <Slider min={0} max={100} value={medicine} onChange={setMedicine} {...sliderTheme} />
                            </div>
                            <div className={styles.valuePillGroup}>
                                <div className={styles.valuePill}>{medicine}</div>
                                <span className={styles.valueUnit}>%</span>
                            </div>
                        </div>

                        <textarea
                            className={styles.textArea}
                            placeholder="Additional information here...."
                            rows={4}
                        />
                    </div>

                    <div className={common.actionRowCentered}>
                        <button className={common.primaryActionWide} type="button">
                            Update shelter
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default UpdateShelter;
