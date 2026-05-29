using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class ProgressaoController : Controller
{
    private DatabaseContext db;
    public ProgressaoController(DatabaseContext db) { this.db = db; }

    private string? UserId => HttpContext.Session.GetString("UserId");
    private ActionResult RequireLogin() => RedirectToAction("Entrar", "Autenticacao");

    public ActionResult Index(string exerciseId)
    {
        if (UserId == null) return RequireLogin();

        var exercise = db.Exercicio.Include(e => e.MuscleGroup).SingleOrDefault(e => e.Id == exerciseId);
        if (exercise == null) return NotFound();

        var records = db.ProgressaoCarga
            .Where(p => p.UserId == UserId && p.ExerciseId == exerciseId)
            .OrderBy(p => p.Date)
            .ToList();

        ViewBag.Exercise = exercise;
        return View(records);
    }

    [HttpGet]
    public ActionResult Adicionar(string exerciseId)
    {
        if (UserId == null) return RequireLogin();

        var exercise = db.Exercicio.SingleOrDefault(e => e.Id == exerciseId);
        if (exercise == null) return NotFound();

        ViewBag.Exercise = exercise;
        return View();
    }

    [HttpPost]
    public ActionResult Adicionar(ProgressaoCarga form)
    {
        if (UserId == null) return RequireLogin();

        if (form.Load < 0 || form.Sets < 1 || form.Reps < 1)
        {
            TempData["Error"] = "Valores inválidos. Séries e repetições devem ser maiores que zero.";
            return RedirectToAction("Adicionar", new { exerciseId = form.ExerciseId });
        }

        form.Id     = Guid.NewGuid().ToString();
        form.UserId = UserId;
        form.Date   = form.Date == default ? DateTime.UtcNow : form.Date;

        db.ProgressaoCarga.Add(form);
        db.SaveChanges();

        TempData["Success"] = $"Carga de {form.Load} kg registrada!";
        return RedirectToAction("Index", new { exerciseId = form.ExerciseId });
    }

    public ActionResult Excluir(string id)
    {
        if (UserId == null) return RequireLogin();

        var record = db.ProgressaoCarga.SingleOrDefault(p => p.Id == id && p.UserId == UserId);
        if (record == null) return NotFound();

        var exerciseId = record.ExerciseId;
        db.ProgressaoCarga.Remove(record);
        db.SaveChanges();

        TempData["Success"] = "Registro excluído.";
        return RedirectToAction("Index", new { exerciseId });
    }
}
