using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class ExercicioController : Controller
{
    private DatabaseContext db;
    public ExercicioController(DatabaseContext db)
    {
        this.db = db;
    }

    private bool IsLoggedIn => HttpContext.Session.GetString("UserId") != null;
    private ActionResult RequireLogin() => RedirectToAction("Entrar", "Autenticacao");

    public ActionResult Index(string muscle, string difficulty, string equipment)
    {
        if (!IsLoggedIn) return RequireLogin();

        var query = db.Exercicio.Include(e => e.MuscleGroup).AsQueryable();

        if (!string.IsNullOrEmpty(muscle))
            query = query.Where(e => e.MuscleGroupId == muscle);

        if (!string.IsNullOrEmpty(difficulty))
            query = query.Where(e => e.Difficulty == difficulty);

        if (!string.IsNullOrEmpty(equipment))
            query = query.Where(e => e.Equipment == equipment);

        ViewBag.Muscle = muscle;
        ViewBag.Difficulty = difficulty;
        ViewBag.Equipment = equipment;
        ViewBag.MuscleGroups = db.GrupoMuscular.ToList();

        return View(query.ToList());
    }

    public ActionResult Detalhes(string id)
    {
        if (!IsLoggedIn) return RequireLogin();
        var ex = db.Exercicio
            .Include(e => e.MuscleGroup)
            .Single(e => e.Id == id);
        return View(ex);
    }

    [HttpGet]
    public ActionResult Criar()
    {
        if (!IsLoggedIn) return RequireLogin();
        ViewBag.MuscleGroups = db.GrupoMuscular.ToList();
        return View();
    }

    [HttpPost]
    public ActionResult Criar(Exercicio e)
    {
        e.Id = Guid.NewGuid().ToString();

        db.Exercicio.Add(e);
        db.SaveChanges();

        return RedirectToAction("Index");
    }

    public ActionResult Excluir(string id)
    {
        if (!IsLoggedIn) return RequireLogin();
        var ex = db.Exercicio.Single(e => e.Id == id);
        db.Exercicio.Remove(ex);
        db.SaveChanges();

        return RedirectToAction("Index");
    }

    [HttpGet]
    public ActionResult Editar(string id)
    {
        if (!IsLoggedIn) return RequireLogin();
        var ex = db.Exercicio.Single(e => e.Id == id);
        ViewBag.MuscleGroups = db.GrupoMuscular.ToList();
        return View(ex);
    }

    [HttpPost]
    public ActionResult Editar(string id, Exercicio form)
    {
        var ex = db.Exercicio.Single(e => e.Id == id);
        ex.Name = form.Name;
        ex.Description = form.Description;
        ex.Difficulty = form.Difficulty;
        ex.Equipment = form.Equipment;
        ex.Steps = form.Steps;
        ex.ImageUrl = form.ImageUrl;
        ex.MuscleGroupId = form.MuscleGroupId;

        db.SaveChanges();
        return RedirectToAction("Index");
    }
}
