import {MdAdd, MdClose, MdEdit} from "react-icons/md";
import {Link} from "react-router-dom";
import common from "../../styles/views-common.module.css";

const shelters = [
    ["Thika Stadium", "Thika, Kiambu", "Active", "45", "60", "30"],
    ["Kisumu Jomo Kenyatta Ground", "Kisumu Central, Kisumu", "Active", "70", "65", "50"],
    ["Madaraka Primary", "Langata, Nairobi", "Active", "80", "55", "85"],
    ["Karura Forest Relief Camp", "Westlands, Nairobi", "Active", "60", "75", "40"],
    ["Thika Level 5 Hospital", "Thika, Kiambu", "Active", "70", "80", "55"],
    ["Nakuru ASK Showground", "Nakuru East, Nakuru", "Active", "65", "55", "45"],
    ["Nakuru ASK Showground", "Nakuru East, Nakuru", "Active", "65", "55", "45"],
];

const ShelterOverview = () => {
    return (
        <div className={common.pageStack}>
            <div className={common.pageHeaderRow}>
                <h1 className={common.pageTitle}>All Shelters</h1>
                <Link className={common.primaryAction} to="/shelters/add">
                    <MdAdd/>
                    <span>Register Shelter</span>
                </Link>
            </div>

            <div className={common.tableShell}>
                <table className={common.dataTable}>
                    <thead>
                    <tr>
                        <th>Name</th>
                        <th>Location</th>
                        <th>Status</th>
                        <th>Food (%)</th>
                        <th>Water (%)</th>
                        <th>Medicine (%)</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    {shelters.map((shelter) => (
                        <tr key={`${shelter[0]}-${shelter[1]}`}>
                            <td>{shelter[0]}</td>
                            <td>{shelter[1]}</td>
                            <td>{shelter[2]}</td>
                            <td>{shelter[3]}</td>
                            <td>{shelter[4]}</td>
                            <td>{shelter[5]}</td>
                            <td>
                                <div className={common.tableActions}>
                                    <Link className={common.inlineAction} to="/shelters/update">
                                        <MdEdit/>
                                        <span>Edit</span>
                                    </Link>
                                    <button className={common.inlineDanger} type="button">
                                        <MdClose/>
                                        <span>Inactive</span>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default ShelterOverview;
