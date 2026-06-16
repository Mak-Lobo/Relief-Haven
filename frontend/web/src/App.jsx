import {BrowserRouter, Route, Routes} from "react-router-dom";
import {Login} from "./pages/authentication/Login";
import Registration from "./pages/authentication/Registration";
import Dashboard from "./pages/views/Dashboard.jsx";
import ShelterOverview from "./pages/views/ShelterOverview.jsx";
import Profile from "./pages/views/Profile.jsx";
import Financials from "./pages/views/Financials.jsx";
import AddShelter from "./pages/views/AddShelter.jsx";
import UpdateShelter from "./pages/views/UpdateShelter.jsx";
import ShelterResources from "./pages/views/ShelterResources.jsx";
import ResourceUpdates from "./pages/views/ResourceUpdates.jsx";
import EditProfile from "./pages/views/EditProfile.jsx";
import {PublicGate, RouteGate} from "./components/RouteGate.jsx";

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/login" element={<PublicGate><Login/></PublicGate>}/>
                <Route path="/register" element={<PublicGate><Registration/></PublicGate>}/>
                <Route path="/" element={<RouteGate/>}>
                    <Route index element={<Dashboard/>}/>
                    <Route path="shelters" element={<ShelterOverview/>}/>
                    <Route path="shelters/add" element={<AddShelter/>}/>
                    <Route path="shelters/update/:shelterId" element={<UpdateShelter/>}/>
                    <Route path="shelters/resources/:shelterId" element={<ShelterResources/>}/>
                    <Route path="resources" element={<ResourceUpdates/>}/>
                    <Route path="financials" element={<Financials/>}/>
                    <Route path="profile" element={<Profile/>}/>
                    <Route path="profile/edit" element={<EditProfile/>}/>
                </Route>
            </Routes>
        </BrowserRouter>
    );
}

export default App;
