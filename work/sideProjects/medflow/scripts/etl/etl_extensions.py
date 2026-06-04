def export_vital_signs(cur, out_file):
    print("Exporting Vital Signs (M_PAPARS -> vital_signs)...")
    try:
        cur.execute("SELECT * FROM M_PAPARS")
        columns = [desc[0].upper() for desc in cur.description]
        out_file.write("\nALTER TABLE vital_signs DISABLE TRIGGER ALL;\n\n")

        count = 0
        rows = []

        for r in cur.fetchall():
            row_dict = dict(zip(columns, r))

            pacid = row_dict.get("PACID")
            if not pacid:
                continue

            pacid += ID_OFFSET
            recorded_at = escape_sql(
                row_dict.get("FECHA", row_dict.get("FEHO", datetime.datetime.now()))
            )

            systolic = escape_sql(row_dict.get("TENARTSIS"))
            diastolic = escape_sql(row_dict.get("TENARTDIA"))
            heart_rate = escape_sql(row_dict.get("FRECCARD"))
            resp_rate = escape_sql(row_dict.get("FRECRESP"))
            temp = escape_sql(row_dict.get("TEMP"))
            weight = escape_sql(row_dict.get("PESO"))
            height = escape_sql(row_dict.get("TALLA"))

            val = f"({pacid}, NULL, NULL, NULL, {recorded_at}, {systolic}, {diastolic}, NULL, {heart_rate}, {resp_rate}, {temp}, NULL, {weight}, {height}, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1)"
            rows.append(val)
            count += 1

            if len(rows) >= 500:
                out_file.write(
                    "INSERT INTO vital_signs (patient_id, event_id, appointment_id, recorded_by, recorded_at, systolic_bp, diastolic_bp, mean_arterial_bp, heart_rate, respiratory_rate, temperature, oxygen_saturation, weight, height, bmi, bmi_classification, body_surface_area, waist_circumference, hip_circumference, waist_hip_ratio, smoking_status, cigarettes_per_day, glucose, hba1c, hemoglobin, hematocrit, creatinine, total_cholesterol, hdl_cholesterol, ldl_cholesterol, triglycerides, tenant_id) VALUES \n"
                    + ",\n".join(rows)
                    + ";\n"
                )
                rows = []

        if rows:
            out_file.write(
                "INSERT INTO vital_signs (patient_id, event_id, appointment_id, recorded_by, recorded_at, systolic_bp, diastolic_bp, mean_arterial_bp, heart_rate, respiratory_rate, temperature, oxygen_saturation, weight, height, bmi, bmi_classification, body_surface_area, waist_circumference, hip_circumference, waist_hip_ratio, smoking_status, cigarettes_per_day, glucose, hba1c, hemoglobin, hematocrit, creatinine, total_cholesterol, hdl_cholesterol, ldl_cholesterol, triglycerides, tenant_id) VALUES \n"
                + ",\n".join(rows)
                + ";\n"
            )

        out_file.write("\nALTER TABLE vital_signs ENABLE TRIGGER ALL;\n")
        print(f"  ✓ Extracted {count} vital signs.")
    except Exception as e:
        print(f"  [SKIPPED] Vital Signs extraction failed: {e}")


def export_prescriptions(cur, out_file):
    print("Exporting Prescriptions (M_ROMMED -> prescriptions/items)...")
    try:
        cur.execute("SELECT * FROM M_ROMMED ORDER BY AGDETAROM_ID, ITEM")
        columns = [desc[0].upper() for desc in cur.description]
        out_file.write("\nALTER TABLE prescriptions DISABLE TRIGGER ALL;\n")
        out_file.write("ALTER TABLE prescription_items DISABLE TRIGGER ALL;\n\n")

        count_p = 0
        count_i = 0
        presc_rows = []
        item_rows = []
        seen_prescriptions = set()

        for r in cur.fetchall():
            row_dict = dict(zip(columns, r))

            rom_id = row_dict.get("AGDETAROM_ID")
            pacid = row_dict.get("PACID")
            if not rom_id or not pacid:
                continue

            pacid += ID_OFFSET
            prescriber = (
                (row_dict.get("USRID") + ID_OFFSET) if row_dict.get("USRID") else "NULL"
            )
            feho = escape_sql(row_dict.get("FEHO", datetime.datetime.now()))

            # Master record
            if rom_id not in seen_prescriptions:
                num_form = escape_sql(row_dict.get("NUM_FORM", f"MIG-{rom_id}"))
                val_p = f"({rom_id}, {pacid}, NULL, NULL, {prescriber}, NULL, {num_form}, {feho}, NULL, NULL, 'completed', {feho}, NULL, FALSE, 1)"
                presc_rows.append(val_p)
                seen_prescriptions.add(rom_id)
                count_p += 1

                if len(presc_rows) >= 500:
                    out_file.write(
                        "INSERT INTO prescriptions (id, patient_id, event_id, appointment_id, prescriber_id, facility_id, prescription_number, prescription_date, diagnosis_code, diagnosis_name, status, valid_until, notes, is_controlled, copies_count) VALUES \n"
                        + ",\n".join(presc_rows)
                        + " ON CONFLICT DO NOTHING;\n"
                    )
                    presc_rows = []

            # Item record
            item_num = row_dict.get("ITEM", 1)
            med_code = escape_sql(row_dict.get("COD_REF"))
            commercial = escape_sql(row_dict.get("DES_CN"))
            active_ing = escape_sql(row_dict.get("DES_PA"))
            form = escape_sql(row_dict.get("DES_FF"))
            qty = row_dict.get("CANTIDAD", 1)
            dosage = escape_sql(row_dict.get("POSOLOGIA"))
            days = row_dict.get("DIAS_TTO", 0)

            val_i = f"({rom_id}, {item_num}, {med_code}, {active_ing}, {commercial}, {form}, NULL, {qty}, {dosage}, NULL, NULL, {days}, FALSE, FALSE, FALSE, NULL)"
            item_rows.append(val_i)
            count_i += 1

            if len(item_rows) >= 500:
                out_file.write(
                    "INSERT INTO prescription_items (prescription_id, item_number, medication_code, active_ingredient, commercial_name, pharmaceutical_form, concentration, quantity, dosage, frequency, route, treatment_days, is_permanent, is_controlled, is_subsidized, notes) VALUES \n"
                    + ",\n".join(item_rows)
                    + ";\n"
                )
                item_rows = []

        if presc_rows:
            out_file.write(
                "INSERT INTO prescriptions (id, patient_id, event_id, appointment_id, prescriber_id, facility_id, prescription_number, prescription_date, diagnosis_code, diagnosis_name, status, valid_until, notes, is_controlled, copies_count) VALUES \n"
                + ",\n".join(presc_rows)
                + " ON CONFLICT DO NOTHING;\n"
            )
        if item_rows:
            out_file.write(
                "INSERT INTO prescription_items (prescription_id, item_number, medication_code, active_ingredient, commercial_name, pharmaceutical_form, concentration, quantity, dosage, frequency, route, treatment_days, is_permanent, is_controlled, is_subsidized, notes) VALUES \n"
                + ",\n".join(item_rows)
                + ";\n"
            )

        out_file.write("\nALTER TABLE prescriptions ENABLE TRIGGER ALL;\n")
        out_file.write("ALTER TABLE prescription_items ENABLE TRIGGER ALL;\n")
        print(f"  ✓ Extracted {count_p} prescriptions and {count_i} items.")
    except Exception as e:
        print(f"  [SKIPPED] Prescriptions extraction failed: {e}")
