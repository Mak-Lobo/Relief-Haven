import {MdEdit, MdLogout} from "react-icons/md";
import common from "../../styles/views-common.module.css";
import styles from "../../styles/profile.module.css";

const profileFields = [
    {label: "First Name", value: "Mark"},
    {label: "Last Name", value: "Njoroge"},
    {label: "Phone number", value: "+2547200177"},
    {label: "Role", value: "Manager - Muranga"},
    {label: "Email Address", value: "markknjoroge@reliefhaven.ac.ke"},
    {label: "Created at", value: "4 Mar, 2025"},
    {label: "Updated at", value: "12 Dec, 2026"},
];

const Profile = () => {
    return (
        <div className={common.pageFrame}>
            <div className={styles.profileOuter}>
                <h1 className={common.pageTitleCentered}>Account Profile</h1>

                <div className={styles.profileCard}>
                    <div className={styles.profileGrid}>
                        {profileFields.map((field) => (
                            <div key={field.label} className={styles.profileField}>
                                <span className={common.fieldLabel}>{field.label}</span>
                                <span className={styles.fieldValue}>{field.value}</span>
                            </div>
                        ))}
                    </div>

                    <div className={common.actionRowCentered}>
                        <button className={common.primaryAction} type="button">
                            <MdEdit/>
                            <span>Edit Profile</span>
                        </button>
                        <button className={common.dangerAction} type="button">
                            <MdLogout/>
                            <span>Logout</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Profile;
