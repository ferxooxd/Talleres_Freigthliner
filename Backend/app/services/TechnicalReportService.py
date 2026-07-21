from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.TechnicalReportEntity import TechnicalReport
from app.models.ServiceOrderEntity import ServiceOrder
from app.models.UserEntity import User
from app.core.Enum import UserRole
from app.schemas.TechnicalReportSchema import TechnicalReportRegister, TechnicalReportUpdate
from app.services.NotificationService import NotificationService, NotificationType

class TechnicalReportService:
    
    @staticmethod
    def create_report(db: Session, report_data: TechnicalReportRegister, id_usuario: int, background_tasks=None):
        # Validate that the User exists
        user = db.query(User).filter(User.id_usuario == id_usuario).first()
        if not user:
            raise HTTPException(status_code=404, detail="El usuario (mecánico) especificado no existe.")
        if user.rol != UserRole.mechanic:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Solo un tecnico puede finalizar reportes tecnicos.",
            )

        # Validate that the ServiceOrder exists
        order = db.query(ServiceOrder).filter(ServiceOrder.id_orden == report_data.id_orden).first()
        if not order:
            raise HTTPException(status_code=404, detail="La orden de servicio especificada no existe.")
        if order.id_mecanico != id_usuario:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="La orden no esta asignada a este tecnico.",
            )

        # Create and save the TechnicalReport
        report_dict = report_data.model_dump()
        report_dict["id_usuario"] = id_usuario
        db_report = TechnicalReport(**report_dict)
        db.add(db_report)
        
        # Update ServiceOrder.informe_trabajo so the frontend knows there's a report
        images_section = ""
        if report_data.imagenes_repuestos:
            images_section = f"\n[IMAGENES]{report_data.imagenes_repuestos}[/IMAGENES]"
        
        order.informe_trabajo = f"Diagnóstico: {report_data.diagnostico}\nRecomendaciones: {report_data.recomendaciones or 'N/A'}{images_section}"
        
        db.commit()
        db.refresh(db_report)
        TechnicalReportService._notify_admins_about_submitted_report(
            db,
            report=db_report,
            order=order,
            mechanic=user,
            background_tasks=background_tasks,
        )
        return db_report

    @staticmethod
    def _notify_admins_about_submitted_report(
        db: Session,
        *,
        report: TechnicalReport,
        order: ServiceOrder,
        mechanic: User,
        background_tasks=None,
    ):
        admin_user_ids = [
            row[0]
            for row in db.query(User.id_usuario)
            .filter(User.rol == UserRole.admin)
            .order_by(User.id_usuario)
            .all()
        ]
        if not admin_user_ids:
            return

        mechanic_name = f"{mechanic.nombre} {mechanic.apellido}"
        vehicle_plate = order.placa_vehiculo or "Sin placa"

        NotificationService.notify(
            user_ids=admin_user_ids,
            type=NotificationType.technical_report_submitted,
            title="Reporte tecnico finalizado",
            body=(
                f"{mechanic_name} finalizo el reporte tecnico de la orden "
                f"{order.numero_orden}. Vehiculo: {vehicle_plate}"
            ),
            data={
                "type": NotificationType.technical_report_submitted.value,
                "report_id": str(report.id_informe_tecnico),
                "order_id": str(order.id_orden),
            },
            background_tasks=background_tasks,
        )

    @staticmethod
    def get_report(db: Session, id_informe_tecnico: int):
        report = db.query(TechnicalReport).filter(TechnicalReport.id_informe_tecnico == id_informe_tecnico).first()
        if not report:
            raise HTTPException(status_code=404, detail="Informe técnico no encontrado.")
        return report

    @staticmethod
    def get_all_reports(db: Session, skip: int = 0, limit: int = 100):
        return db.query(TechnicalReport).offset(skip).limit(limit).all()

    @staticmethod
    def update_report(db: Session, id_informe_tecnico: int, update_data: TechnicalReportUpdate):
        db_report = TechnicalReportService.get_report(db, id_informe_tecnico)
        
        update_dict = update_data.model_dump(exclude_unset=True)
        for key, value in update_dict.items():
            setattr(db_report, key, value)
            
        db.commit()
        db.refresh(db_report)
        return db_report

    @staticmethod
    def delete_report(db: Session, id_informe_tecnico: int):
        db_report = TechnicalReportService.get_report(db, id_informe_tecnico)
        
        db.delete(db_report)
        db.commit()
        return {"message": "Informe técnico eliminado exitosamente"}
